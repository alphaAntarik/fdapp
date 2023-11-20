// SPDX-License-Identifier: MIT
//pragma solidity >=0.4.22 <0.9.0;

pragma solidity >=0.5.16 <0.9.0;
pragma experimental ABIEncoderV2;

contract UsersContract {
    uint256 public userCount = 0;

    struct User {
        uint256 id;
        string name;
        string surname;
    }

    User[] public allusers;

    mapping(uint256 => User) public users;

    event UserCreated(uint256 id, string name, string surname);
    event UserDeleted(uint256 id);

    function createUser(string memory _name, string memory _surname) public {
        users[userCount] = User(userCount, _name, _surname);
        allusers.push(User(userCount, _name, _surname));
        emit UserCreated(userCount, _name, _surname);
        userCount++;
    }

    function getAllUsers() public view returns (User[] memory) {
        return allusers;
    }

    function deleteUser(uint256 _id) public {
        //require(_id < userCount, "Invalid user ID");

        // Find the index of the user to be deleted in the allusers array
        uint256 indexToDelete = 0;
        for (uint256 i = 0; i < allusers.length; i++) {
            if (allusers[i].id == _id) {
                indexToDelete = i;
                break;
            }
        }

        for (uint256 i = _id; i < allusers.length - 1; i++) {
            // Move each element to the previous position
            allusers[i] = allusers[i + 1];
        }

        // Reduce the array length by 1
        allusers.pop();

        // Delete user from users mapping
        delete users[_id];

        emit UserDeleted(_id);
        userCount--;
    }
}
