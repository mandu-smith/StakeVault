# StakeVault 🎯

**Next-Generation Bitcoin Prediction Market Platform**

[![Stacks](https://img.shields.io/badge/Stacks-Blockchain-purple)](https://stacks.co)
[![Clarity](https://img.shields.io/badge/Clarity-Smart%20Contract-blue)](https://clarity-lang.org/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

## Overview

StakeVault is a sophisticated decentralized prediction market platform that transforms Bitcoin price speculation into strategic investment opportunities through community-driven consensus mechanisms and algorithmic reward distribution. Built on the Stacks blockchain, StakeVault leverages institutional-grade security protocols and oracle-integrated price feeds to create a transparent, fair, and profitable prediction market ecosystem.

## 🚀 Key Features

- **Binary Directional Markets**: Bullish/bearish Bitcoin price predictions
- **Proportional Reward System**: Stake-weighted reward distribution
- **Oracle Integration**: Real-time Bitcoin price feeds for accurate market resolution
- **Dynamic Thresholds**: Configurable minimum stakes and fee structures
- **Automated Lifecycle**: Self-managing market creation, resolution, and payouts
- **Institutional Security**: Advanced fund protection and transparency mechanisms
- **Community Governance**: Decentralized platform management

## 🏗️ System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        StakeVault Platform                      │
├─────────────────────────────────────────────────────────────────┤
│  Frontend Interface  │  Smart Contract  │  Oracle Integration  │
│  ┌─────────────────┐ │  ┌─────────────┐ │  ┌─────────────────┐ │
│  │  User Dashboard │ │  │  StakeVault │ │  │  Price Oracle   │ │
│  │  Market Display │ │  │  Contract   │ │  │  Integration    │ │
│  │  Wallet Connect │ │  │  (Clarity)  │ │  │                 │ │
│  └─────────────────┘ │  └─────────────┘ │  └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
           │                       │                       │
           │                       │                       │
           ▼                       ▼                       ▼
    ┌─────────────┐         ┌─────────────┐         ┌─────────────┐
    │   Users     │         │   Stacks    │         │  Bitcoin    │
    │  (STX       │◄────────┤ Blockchain  │◄────────┤ Price Feed  │
    │ Stakers)    │         │             │         │             │
    └─────────────┘         └─────────────┘         └─────────────┘
```

### Contract Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                     StakeVault Smart Contract                  │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐│
│  │   Market        │  │   Prediction    │  │   Rewards       ││
│  │   Management    │  │   Engine        │  │   Distribution  ││
│  │                 │  │                 │  │                 ││
│  │ • create-market │  │ • make-prediction│  │ • claim-winnings││
│  │ • resolve-market│  │ • validate-stake │  │ • calculate-fees││
│  │ • market-lifecycle│ │ • track-positions│  │ • proportional  ││
│  │                 │  │                 │  │   payouts       ││
│  └─────────────────┘  └─────────────────┘  └─────────────────┘│
│                                                                │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐│
│  │   Data Storage  │  │   Access Control│  │   Configuration ││
│  │                 │  │                 │  │                 ││
│  │ • markets map   │  │ • owner-only    │  │ • minimum-stake ││
│  │ • user-predictions│ │ • oracle-auth   │  │ • fee-percentage││
│  │ • market-counter│  │ • user-claims   │  │ • oracle-address││
│  │                 │  │                 │  │                 ││
│  └─────────────────┘  └─────────────────┘  └─────────────────┘│
└────────────────────────────────────────────────────────────────┘
```

## 📊 Data Flow

### Market Creation & Prediction Flow

```
1. Market Creation
   Owner → create-market(start-price, start-block, end-block)
   ↓
   Contract validates parameters
   ↓
   Market stored in markets map
   ↓
   Market ID returned

2. User Prediction
   User → make-prediction(market-id, "up"/"down", stake-amount)
   ↓
   Contract validates market timing & stake
   ↓
   STX transferred to contract
   ↓
   Prediction stored in user-predictions map
   ↓
   Market totals updated

3. Market Resolution
   Oracle → resolve-market(market-id, end-price)
   ↓
   Contract validates oracle authorization
   ↓
   Market marked as resolved
   ↓
   Winning direction determined

4. Reward Distribution
   Winner → claim-winnings(market-id)
   ↓
   Contract calculates proportional winnings
   ↓
   Platform fee deducted
   ↓
   Payout transferred to user
   ↓
   Prediction marked as claimed
```

### Financial Flow

```
STX Input Flow:
User Stake → Contract Pool → [Market Resolution] → Winners Pool
                    ↓
                Platform Fee → Contract Owner

Reward Calculation:
User Winnings = (User Stake / Total Winning Stake) × Total Pool
Final Payout = User Winnings - Platform Fee
```

## 🔧 Technical Specifications

### Smart Contract Details

- **Blockchain**: Stacks
- **Language**: Clarity
- **Token**: STX (Stacks Token)
- **Minimum Stake**: 1 STX (1,000,000 microSTX)
- **Platform Fee**: 2% (configurable)
- **Oracle Integration**: External price feed validation

### Data Structures

```clarity
;; Market Structure
{
  start-price: uint,      ;; Initial BTC price
  end-price: uint,        ;; Final BTC price
  total-up-stake: uint,   ;; Total bullish stakes
  total-down-stake: uint, ;; Total bearish stakes
  start-block: uint,      ;; Market activation block
  end-block: uint,        ;; Market expiration block
  resolved: bool          ;; Resolution status
}

;; User Prediction Structure
{
  prediction: string-ascii,  ;; "up" or "down"
  stake: uint,              ;; Stake amount
  claimed: bool             ;; Claim status
}
```

## 🛠️ Installation & Deployment

### Prerequisites

```bash
# Install Clarinet CLI
npm install -g @hirosystems/clarinet-cli

# Install Stacks CLI
npm install -g @stacks/cli
```

### Local Development

```bash
# Clone repository
git clone https://github.com/your-org/stakevault
cd stakevault

# Initialize Clarinet project
clarinet new stakevault
cd stakevault

# Add contract
cp path/to/stakevault.clar contracts/

# Test contract
clarinet test

# Deploy locally
clarinet deploy --testnet
```

### Mainnet Deployment

```bash
# Deploy to Stacks mainnet
stx deploy_contract stakevault stakevault.clar \
  --network mainnet \
  --private-key your-private-key
```

## 📈 Usage Examples

### Creating a Market

```clarity
;; Create a 24-hour Bitcoin prediction market
(contract-call? .stakevault create-market 
  u50000    ;; Start price: $50,000
  u100000   ;; Start block
  u100144   ;; End block (24h later)
)
```

### Making a Prediction

```clarity
;; Stake 5 STX on Bitcoin going up
(contract-call? .stakevault make-prediction 
  u0              ;; Market ID
  "up"            ;; Prediction direction
  u5000000        ;; Stake: 5 STX
)
```

### Claiming Winnings

```clarity
;; Claim proportional winnings after market resolution
(contract-call? .stakevault claim-winnings u0)
```

## 🔐 Security Features

- **Oracle Authorization**: Only authorized oracles can resolve markets
- **Ownership Controls**: Administrative functions restricted to contract owner
- **Stake Validation**: Minimum stake requirements and balance checks
- **Double-Claim Protection**: Prevents multiple reward claims
- **Parameter Validation**: Comprehensive input validation and error handling

## 🎯 Roadmap

- **Phase 1**: Core prediction market functionality ✅
- **Phase 2**: Multi-asset prediction markets
- **Phase 3**: Advanced market types (ranges, time-based)
- **Phase 4**: Governance token integration
- **Phase 5**: Cross-chain compatibility

## 🤝 Contributing

We welcome contributions! Please read our [Contributing Guidelines](CONTRIBUTING.md) for details on our code of conduct and development process.

### Development Setup

```bash
# Fork the repository
git clone https://github.com/your-username/stakevault
cd stakevault

# Create feature branch
git checkout -b feature/your-feature

# Make changes and test
clarinet test

# Submit pull request
