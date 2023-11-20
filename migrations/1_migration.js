const UserContract = artifacts.require("UsersContract");

module.exports = function (deployer) {
  deployer.deploy(UserContract);
};
