const fs = require("fs");
const path = require("path");
const { ethers } = require("hardhat");

async function main() {
  const [owner, voter1, voter2] = await ethers.getSigners();
  console.log("Deploy dei contratti con l'account:", owner.address);

  // 1. Deploy del contratto Membership
  console.log("Inizio deploy di Membership...");
  const Membership = await ethers.getContractFactory("Membership");
  const membership = await Membership.deploy();
  const membershipAddress = await membership.getAddress();
  console.log(`✅ Contratto Membership deployato a: ${membershipAddress}`);

  // 2. Deploy del contratto Voting, passando l'indirizzo di Membership
  console.log("Inizio deploy di Voting...");
  const Voting = await ethers.getContractFactory("Voting");
  const voting = await Voting.deploy(membershipAddress);
  const votingAddress = await voting.getAddress();
  console.log(`✅ Contratto Voting deployato a: ${votingAddress}`);

  // 3. Mint di alcuni NFT per gli account di test
  console.log("Inizio minting degli NFT di membership...");
  await membership.connect(owner).mint(owner.address);
  console.log(`- 1 NFT mintato per l'owner (${owner.address})`);
  await membership.connect(owner).mint(voter1.address);
  console.log(`- 1 NFT mintato per il voter1 (${voter1.address})`);
  await membership.connect(owner).mint(voter2.address);
  console.log(`- 1 NFT mintato per il voter2 (${voter2.address})`);
  console.log("✅ Minting completato.");

  // 4. Salvataggio delle informazioni dei contratti per il frontend
  const votingAbi = require("../artifacts/contracts/Voting.sol/Voting.json").abi;
  const membershipAbi = require("../artifacts/contracts/Membership.sol/Membership.json").abi;

  const contractInfo = {
    voting: {
      address: votingAddress,
      abi: votingAbi,
    },
    membership: {
      address: membershipAddress,
      abi: membershipAbi,
    },
  };

  const data = `export const contractInfo = ${JSON.stringify(contractInfo, null, 2)};\n`;

  try {
    fs.writeFileSync(path.join(__dirname, "../frontend/contractInfo.js"), data);
    console.log("✅ ABI e indirizzi dei contratti salvati in frontend/contractInfo.js");
  } catch (error) {
    console.error("Errore durante la scrittura del file contractInfo.js:", error);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
