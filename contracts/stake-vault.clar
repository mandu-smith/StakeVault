;; StakeVault - Next-Generation Bitcoin Prediction Market
;;
;; Summary:
;;   A sophisticated decentralized prediction market platform that transforms
;;   Bitcoin price speculation into a strategic investment opportunity through
;;   community-driven consensus mechanisms and algorithmic reward distribution.
;;
;; Description:
;;   StakeVault revolutionizes cryptocurrency prediction markets by creating
;;   a transparent, community-governed platform where participants can leverage
;;   their market insights to earn rewards. The platform employs advanced
;;   oracle integration for price feeds, implements dynamic reward algorithms
;;   based on stake proportions, and maintains institutional-grade security
;;   protocols. Users stake STX tokens on directional Bitcoin price movements,
;;   with winners earning proportional rewards from the collective pool after
;;   automated fee distribution and market resolution.
;;
;; Key Features:
;;   - Binary directional markets (bullish/bearish predictions)
;;   - Proportional reward distribution based on stake weight
;;   - Oracle-integrated price resolution system
;;   - Dynamic minimum stake thresholds
;;   - Automated market lifecycle management
;;   - Real-time market analytics and transparency
;;   - Institutional-grade fund protection mechanisms
;;

;; SYSTEM CONSTANTS & ERROR DEFINITIONS

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_MARKET_NOT_FOUND (err u101))
(define-constant ERR_INVALID_PREDICTION_TYPE (err u102))
(define-constant ERR_MARKET_INACTIVE (err u103))
(define-constant ERR_REWARDS_ALREADY_CLAIMED (err u104))
(define-constant ERR_INSUFFICIENT_FUNDS (err u105))
(define-constant ERR_INVALID_PARAMETERS (err u106))
(define-constant ERR_MARKET_NOT_STARTED (err u107))
(define-constant ERR_MARKET_EXPIRED (err u108))
(define-constant ERR_MARKET_ALREADY_RESOLVED (err u109))

;; CONFIGURATION VARIABLES

;; Oracle address for external price data integration
(define-data-var oracle-address principal 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

;; Minimum stake requirement (1 STX = 1,000,000 microSTX)
(define-data-var minimum-stake uint u1000000)

;; Platform fee percentage (2% = 200 basis points)
(define-data-var fee-percentage uint u2)

;; Global market counter for unique identification
(define-data-var market-counter uint u0)

;; DATA STRUCTURES

;; Market registry with comprehensive market data
(define-map markets
  uint ;; market-id
  {
    start-price: uint,      ;; Initial Bitcoin price at market creation
    end-price: uint,        ;; Final Bitcoin price at resolution
    total-up-stake: uint,   ;; Total STX staked on bullish predictions
    total-down-stake: uint, ;; Total STX staked on bearish predictions
    start-block: uint,      ;; Market activation block height
    end-block: uint,        ;; Market expiration block height
    resolved: bool          ;; Market resolution status
  }
)

;; User prediction tracking system
(define-map user-predictions
  {market-id: uint, user: principal}
  {
    prediction: (string-ascii 4), ;; "up" or "down"
    stake: uint,                  ;; Amount staked in microSTX
    claimed: bool                 ;; Reward claim status
  }
)

;; CORE MARKET FUNCTIONS

;; Creates a new prediction market with specified parameters
(define-public (create-market (start-price uint) (start-block uint) (end-block uint))
  (let
    ((market-id (var-get market-counter)))
    
    ;; Validate caller authorization
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    
    ;; Validate market parameters
    (asserts! (> end-block start-block) ERR_INVALID_PARAMETERS)
    (asserts! (> start-price u0) ERR_INVALID_PARAMETERS)
    
    ;; Initialize market data structure
    (map-set markets market-id
      {
        start-price: start-price,
        end-price: u0,
        total-up-stake: u0,
        total-down-stake: u0,
        start-block: start-block,
        end-block: end-block,
        resolved: false
      }
    )
    
    ;; Increment market counter
    (var-set market-counter (+ market-id u1))
    
    (ok market-id)
  )
)

;; Places a directional prediction in an active market
(define-public (make-prediction (market-id uint) (prediction (string-ascii 4)) (stake uint))
  (let
    (
      (market (unwrap! (map-get? markets market-id) ERR_MARKET_NOT_FOUND))
      (current-block-height stacks-block-height)
    )
    
    ;; Validate market timing
    (asserts! (and (>= current-block-height (get start-block market)) 
                   (< current-block-height (get end-block market))) 
              ERR_MARKET_EXPIRED)
    
    ;; Validate prediction type
    (asserts! (or (is-eq prediction "up") (is-eq prediction "down")) 
              ERR_INVALID_PREDICTION_TYPE)
    
    ;; Validate stake amount
    (asserts! (>= stake (var-get minimum-stake)) ERR_INVALID_PREDICTION_TYPE)
    (asserts! (<= stake (stx-get-balance tx-sender)) ERR_INSUFFICIENT_FUNDS)
    
    ;; Transfer stake to contract
    (try! (stx-transfer? stake tx-sender (as-contract tx-sender)))
    
    ;; Record user prediction
    (map-set user-predictions {market-id: market-id, user: tx-sender}
      {prediction: prediction, stake: stake, claimed: false}
    )
    
    ;; Update market totals
    (map-set markets market-id
      (merge market
        {
          total-up-stake: (if (is-eq prediction "up")
                           (+ (get total-up-stake market) stake)
                           (get total-up-stake market)),
          total-down-stake: (if (is-eq prediction "down")
                            (+ (get total-down-stake market) stake)
                            (get total-down-stake market))
        }
      )
    )
    
    (ok true)
  )
)

;; Resolves market with final Bitcoin price from oracle
(define-public (resolve-market (market-id uint) (end-price uint))
  (let
    ((market (unwrap! (map-get? markets market-id) ERR_MARKET_NOT_FOUND)))
    
    ;; Validate oracle authorization
    (asserts! (is-eq tx-sender (var-get oracle-address)) ERR_UNAUTHORIZED)
    
    ;; Validate market timing
    (asserts! (>= stacks-block-height (get end-block market)) ERR_MARKET_EXPIRED)
    
    ;; Ensure market not already resolved
    (asserts! (not (get resolved market)) ERR_MARKET_ALREADY_RESOLVED)
    
    ;; Validate price data
    (asserts! (> end-price u0) ERR_INVALID_PARAMETERS)
    
    ;; Update market with resolution data
    (map-set markets market-id
      (merge market
        {
          end-price: end-price,
          resolved: true
        }
      )
    )
    
    (ok true)
  )
)