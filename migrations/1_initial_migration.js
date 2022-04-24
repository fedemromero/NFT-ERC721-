const Migrations = artifacts.require("Migrations");
const ERC165 = artifacts.require("ERC165");
const Token721 = artifacts.require("Token721");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(ERC165);
  deployer.deploy(Token721);
};
