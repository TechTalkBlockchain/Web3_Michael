import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const ERC20Module = buildModule("ERC20Module", (m) => {

  const erc = m.contract("ERC20Token")

  return { erc };
});

export default ERC20Module;
