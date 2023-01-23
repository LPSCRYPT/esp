// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

// MUD core

/**
 * @title Partial ERC173 interface needed by internal functions
 */
interface IERC173Internal {
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}

/**
 * @title Contract ownership standard interface
 * @dev see https://eips.ethereum.org/EIPS/eip-173
 */
interface IERC173 is IERC173Internal {
  /**
   * @notice get the ERC173 contract owner
   * @return conrtact owner
   */
  function owner() external view returns (address);

  /**
   * @notice transfer contract ownership to new account
   * @param account address of new owner
   */
  function transferOwnership(address account) external;
}

// The minimum requirement for a system is to have an `execute` function.
// For convenience having an `executeTyped` function with typed arguments is recommended.
interface ISystem is IERC173 {
  function execute(bytes memory args) external returns (bytes memory);
}

interface IOwnableWritable is IERC173 {
  function authorizeWriter(address writer) external;

  function unauthorizeWriter(address writer) external;
}

/**
 * Enum of supported schema types
 */
library LibTypes {
  enum SchemaValue {
    BOOL,
    INT8,
    INT16,
    INT32,
    INT64,
    INT128,
    INT256,
    INT,
    UINT8,
    UINT16,
    UINT32,
    UINT64,
    UINT128,
    UINT256,
    BYTES,
    STRING,
    ADDRESS,
    BYTES4,
    BOOL_ARRAY,
    INT8_ARRAY,
    INT16_ARRAY,
    INT32_ARRAY,
    INT64_ARRAY,
    INT128_ARRAY,
    INT256_ARRAY,
    INT_ARRAY,
    UINT8_ARRAY,
    UINT16_ARRAY,
    UINT32_ARRAY,
    UINT64_ARRAY,
    UINT128_ARRAY,
    UINT256_ARRAY,
    BYTES_ARRAY,
    STRING_ARRAY
  }
}

interface IComponent is IOwnableWritable {
  /** Return the keys and value types of the schema of this component. */
  function getSchema() external pure returns (string[] memory keys, LibTypes.SchemaValue[] memory values);

  function set(uint256 entity, bytes memory value) external;

  function remove(uint256 entity) external;

  function has(uint256 entity) external view returns (bool);

  function getRawValue(uint256 entity) external view returns (bytes memory);

  function getEntities() external view returns (uint256[] memory);

  function getEntitiesWithValue(bytes memory value) external view returns (uint256[] memory);

  function registerIndexer(address indexer) external;

  function world() external view returns (address);
}

// create a user defined type that is a pointer to memory
type Array is bytes32;

/* 
Memory layout:
offset..offset+32: current first unset element (cheaper to have it first most of the time), aka "length"
offset+32..offset+64: capacity of elements in array
offset+64..offset+64+(capacity*32): elements

nominclature:
 - capacity: total number of elements able to be stored prior to having to perform a move
 - length/current unset index: the number of defined items in the array

a dynamic array is such a primitive data structure that it should be extremely optimized. so everything is in assembly
*/
library ArrayLib {
  function newArray(uint16 capacityHint) internal pure returns (Array s) {
    assembly ("memory-safe") {
      // grab free mem ptr
      s := mload(0x40)

      // update free memory pointer based on array's layout:
      //  + 32 bytes for capacity
      //  + 32 bytes for current unset pointer/length
      //  + 32*capacity
      //  + current free memory pointer (s is equal to mload(0x40))
      mstore(0x40, add(s, mul(add(0x02, capacityHint), 0x20)))

      // store the capacity in the second word (see memory layout above)
      mstore(add(0x20, s), capacityHint)

      // store length as 0 because otherwise the compiler may have rugged us
      mstore(s, 0x00)
    }
  }

  // capacity of elements before a move would occur
  function capacity(Array self) internal pure returns (uint256 cap) {
    assembly ("memory-safe") {
      cap := mload(add(0x20, self))
    }
  }

  // number of set elements in the array
  function length(Array self) internal pure returns (uint256 len) {
    assembly ("memory-safe") {
      len := mload(self)
    }
  }

  // gets a ptr to an element
  function unsafe_ptrToElement(Array self, uint256 index) internal pure returns (bytes32 ptr) {
    assembly ("memory-safe") {
      ptr := add(self, mul(0x20, add(0x02, index)))
    }
  }

  // overloaded to default push function with 0 overallocation
  function push(Array self, uint256 elem) internal view returns (Array ret) {
    ret = push(self, elem, 0);
  }

  // push an element safely into the array - will perform a move if needed as well as updating the free memory pointer
  // returns the new pointer.
  //
  // WARNING: if a move occurs, the user *must* update their pointer, thus the returned updated pointer. safest
  // method is *always* updating the pointer
  function push(
    Array self,
    uint256 elem,
    uint256 overalloc
  ) internal view returns (Array) {
    Array ret;
    assembly ("memory-safe") {
      // set the return ptr
      ret := self
      // check if length == capacity (meaning no more preallocated space)
      switch eq(mload(self), mload(add(0x20, self)))
      case 1 {
        // optimization: check if the free memory pointer is equal to the end of the preallocated space
        // if it is, we can just natively extend the array because nothing has been allocated *after*
        // us. i.e.:
        // evm_memory = [00...free_mem_ptr...Array.length...Array.lastElement]
        // this check compares free_mem_ptr to Array.lastElement, if they are equal, we know there is nothing after
        //
        // optimization 2: length == capacity in this case (per above) so we can avoid an add to look at capacity
        // to calculate where the last element it
        switch eq(mload(0x40), add(self, mul(add(0x02, mload(self)), 0x20)))
        case 1 {
          // the free memory pointer hasn't moved, i.e. free_mem_ptr == Array.lastElement, just extend

          // Add 1 to the Array.capacity
          mstore(add(0x20, self), add(0x01, mload(add(0x20, self))))

          // the free mem ptr is where we want to place the next element
          mstore(mload(0x40), elem)

          // move the free_mem_ptr by a word (32 bytes. 0x20 in hex)
          mstore(0x40, add(0x20, mload(0x40)))

          // update the length
          mstore(self, add(0x01, mload(self)))
        }
        default {
          // we couldn't do the above optimization, use the `identity` precompile to perform a memory move

          // move the array to the free mem ptr by using the identity precompile which just returns the values
          let array_size := mul(add(0x02, mload(self)), 0x20)
          pop(
            staticcall(
              gas(), // pass gas
              0x04, // call identity precompile address
              self, // arg offset == pointer to self
              array_size, // arg size: capacity + 2 * word_size (we add 2 to capacity to account for capacity and length words)
              mload(0x40), // set return buffer to free mem ptr
              array_size // identity just returns the bytes of the input so equal to argsize
            )
          )

          // add the element to the end of the array
          mstore(add(mload(0x40), array_size), elem)

          // add to the capacity
          mstore(
            add(0x20, mload(0x40)), // free_mem_ptr + word == new capacity word
            add(add(0x01, overalloc), mload(add(0x20, mload(0x40)))) // add one + overalloc to capacity
          )

          // add to length
          mstore(mload(0x40), add(0x01, mload(mload(0x40))))

          // set the return ptr to the new array
          ret := mload(0x40)

          // update free memory pointer
          // we also over allocate if requested
          mstore(0x40, add(add(array_size, add(0x20, mul(overalloc, 0x20))), mload(0x40)))
        }
      }
      default {
        // we have capacity for the new element, store it
        mstore(
          // mem_loc := capacity_ptr + (capacity + 2) * 32
          // we add 2 to capacity to acct for capacity and length words, then multiply by element size
          add(self, mul(add(0x02, mload(self)), 0x20)),
          elem
        )

        // update length
        mstore(self, add(0x01, mload(self)))
      }
    }
    return ret;
  }

  // used when you *guarantee* that the array has the capacity available to be pushed to.
  // no need to update return pointer in this case
  //
  // NOTE: marked as memory safe, but potentially not memory safe if the safety contract is broken by the caller
  function unsafe_push(Array self, uint256 elem) internal pure {
    assembly ("memory-safe") {
      mstore(
        // mem_loc := capacity_ptr + (capacity + 2) * 32
        // we add 2 to capacity to acct for capacity and length words, then multiply by element size
        add(self, mul(add(0x02, mload(self)), 0x20)),
        elem
      )

      // update length
      mstore(self, add(0x01, mload(self)))
    }
  }

  // used when you *guarantee* that the index, i, is within the bounds of length
  // NOTE: marked as memory safe, but potentially not memory safe if the safety contract is broken by the caller
  function unsafe_set(
    Array self,
    uint256 i,
    uint256 value
  ) internal pure {
    assembly ("memory-safe") {
      mstore(add(self, mul(0x20, add(0x02, i))), value)
    }
  }

  function set(
    Array self,
    uint256 i,
    uint256 value
  ) internal pure {
    // if the index is greater than or equal to the capacity, revert
    assembly ("memory-safe") {
      if lt(mload(add(0x20, self)), i) {
        // emit compiler native Panic(uint256) style error
        mstore(0x00, 0x4e487b7100000000000000000000000000000000000000000000000000000000)
        mstore(0x04, 0x32)
        revert(0, 0x24)
      }
      mstore(add(self, mul(0x20, add(0x02, i))), value)
    }
  }

  // used when you *guarantee* that the index, i, is within the bounds of length
  // NOTE: marked as memory safe, but potentially not memory safe if the safety contract is broken by the caller
  function unsafe_get(Array self, uint256 i) internal pure returns (uint256 s) {
    assembly ("memory-safe") {
      s := mload(add(self, mul(0x20, add(0x02, i))))
    }
  }

  // a safe `get` that checks capacity
  function get(Array self, uint256 i) internal pure returns (uint256 s) {
    // if the index is greater than or equal to the capacity, revert
    assembly ("memory-safe") {
      if lt(mload(add(0x20, self)), i) {
        // emit compiler native Panic(uint256) style error
        mstore(0x00, 0x4e487b7100000000000000000000000000000000000000000000000000000000)
        mstore(0x04, 0x32)
        revert(0, 0x24)
      }
      s := mload(add(self, mul(0x20, add(0x02, i))))
    }
  }
}

// A wrapper around the lower level array that does one layer of indirection so that the pointer
// the user has to hold never moves. Effectively a reference to the array. i.e. push doesn't return anything
// because it doesnt need to. Slightly less efficient, generally adds 1-3 memops per func
library RefArrayLib {
  using ArrayLib for Array;

  function newArray(uint16 capacityHint) internal pure returns (Array s) {
    Array referenced = ArrayLib.newArray(capacityHint);
    assembly ("memory-safe") {
      // grab free memory pointer for return value
      s := mload(0x40)
      // store referenced array in s
      mstore(mload(0x40), referenced)
      // update free mem ptr
      mstore(0x40, add(mload(0x40), 0x20))
    }
  }

  // capacity of elements before a move would occur
  function capacity(Array self) internal pure returns (uint256 cap) {
    assembly ("memory-safe") {
      cap := mload(add(0x20, mload(self)))
    }
  }

  // number of set elements in the array
  function length(Array self) internal pure returns (uint256 len) {
    assembly ("memory-safe") {
      len := mload(mload(self))
    }
  }

  // gets a ptr to an element
  function unsafe_ptrToElement(Array self, uint256 index) internal pure returns (bytes32 ptr) {
    assembly ("memory-safe") {
      ptr := add(mload(self), mul(0x20, add(0x02, index)))
    }
  }

  // overloaded to default push function with 0 overallocation
  function push(Array self, uint256 elem) internal view {
    push(self, elem, 0);
  }

  // dereferences the array
  function deref(Array self) internal pure returns (Array s) {
    assembly ("memory-safe") {
      s := mload(self)
    }
  }

  // push an element safely into the array - will perform a move if needed as well as updating the free memory pointer
  function push(
    Array self,
    uint256 elem,
    uint256 overalloc
  ) internal view {
    Array newArr = deref(self).push(elem, overalloc);
    assembly ("memory-safe") {
      // we always just update the pointer because it is cheaper to do so than check whether
      // the array moved
      mstore(self, newArr)
    }
  }

  // used when you *guarantee* that the array has the capacity available to be pushed to.
  // no need to update return pointer in this case
  function unsafe_push(Array self, uint256 elem) internal pure {
    // no need to update pointer
    deref(self).unsafe_push(elem);
  }

  // used when you *guarantee* that the index, i, is within the bounds of length
  // NOTE: marked as memory safe, but potentially not memory safe if the safety contract is broken by the caller
  function unsafe_set(
    Array self,
    uint256 i,
    uint256 value
  ) internal pure {
    deref(self).unsafe_set(i, value);
  }

  function set(
    Array self,
    uint256 i,
    uint256 value
  ) internal pure {
    deref(self).set(i, value);
  }

  // used when you *guarantee* that the index, i, is within the bounds of length
  // NOTE: marked as memory safe, but potentially not memory safe if the safety contract is broken by the caller
  function unsafe_get(Array self, uint256 i) internal pure returns (uint256 s) {
    s = deref(self).unsafe_get(i);
  }

  // a safe `get` that checks capacity
  function get(Array self, uint256 i) internal pure returns (uint256 s) {
    s = deref(self).get(i);
  }
}

type LinkedList is bytes32;

// A basic wrapper around an array that returns a pointer to an element in
// the array. Unfortunately without generics, the user has to cast from a pointer to a type
// held in memory manually
//
// is indexable
//
// data structure:
//   |-----------------------------|                      |-------|
//   |                             v                      |       v
// [ptr, ptr2, ptr3, ptr4]         {value, other value, next}     {value, other value, next}
//        |                                                       ^
//        |-------------------------------------------------------|
//
// where `mload(add(ptr, linkingOffset))` (aka `next`) == ptr2

library IndexableLinkedListLib {
  using ArrayLib for Array;

  function newIndexableLinkedList(uint16 capacityHint) internal pure returns (LinkedList s) {
    s = LinkedList.wrap(Array.unwrap(ArrayLib.newArray(capacityHint)));
  }

  function capacity(LinkedList self) internal pure returns (uint256 cap) {
    cap = Array.wrap(LinkedList.unwrap(self)).capacity();
  }

  function length(LinkedList self) internal pure returns (uint256 len) {
    len = Array.wrap(LinkedList.unwrap(self)).length();
  }

  function push_no_link(LinkedList self, bytes32 element) internal view returns (LinkedList s) {
    s = LinkedList.wrap(Array.unwrap(Array.wrap(LinkedList.unwrap(self)).push(uint256(element))));
  }

  // linkingOffset is the offset from the element ptr that is written to
  function push_and_link(
    LinkedList self,
    bytes32 element,
    uint256 linkingOffset
  ) internal view returns (LinkedList s) {
    Array asArray = Array.wrap(LinkedList.unwrap(self));

    uint256 len = asArray.length();
    if (len == 0) {
      // nothing to link to
      Array arrayS = asArray.push(uint256(element), 3);
      s = LinkedList.wrap(Array.unwrap(arrayS));
    } else {
      // over alloc by 3
      Array arrayS = asArray.push(uint256(element), 3);
      uint256 newPtr = arrayS.unsafe_get(len);
      uint256 lastPtr = arrayS.unsafe_get(len - 1);

      // link the previous element with the new element
      assembly ("memory-safe") {
        mstore(add(lastPtr, linkingOffset), newPtr)
      }

      s = LinkedList.wrap(Array.unwrap(arrayS));
    }
  }

  function next(
    LinkedList, /*self*/
    bytes32 element,
    uint256 linkingOffset
  ) internal pure returns (bool exists, bytes32 elem) {
    assembly ("memory-safe") {
      elem := mload(add(element, linkingOffset))
      exists := gt(elem, 0x00)
    }
  }

  function get(LinkedList self, uint256 index) internal pure returns (bytes32 elementPointer) {
    elementPointer = bytes32(Array.wrap(LinkedList.unwrap(self)).get(index));
  }

  function unsafe_get(LinkedList self, uint256 index) internal pure returns (bytes32 elementPointer) {
    elementPointer = bytes32(Array.wrap(LinkedList.unwrap(self)).unsafe_get(index));
  }
}

// the only way to traverse is to start at head and iterate via `next`. More memory efficient, better for maps
//
// data structure:
//   |-------------------------tail----------------------------|
//   |head|                                           |--------|
//   |    v                                           |        v
//  head, dataStruct{.., next} }     dataStruct{.., next}     dataStruct{.., next}
//                          |          ^
//                          |----------|
//
// `head` is a packed word split as 80, 80, 80 of linking offset, ptr to first element, ptr to last element
// `head` *isn't* stored in memory because it fits in a word

library LinkedListLib {
  uint256 constant HEAD_MASK = 0xFFFFFFFFFFFFFFFFFFFF00000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF;
  uint256 constant TAIL_MASK = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000000;

  function newLinkedList(uint80 _linkingOffset) internal pure returns (LinkedList s) {
    assembly ("memory-safe") {
      s := shl(176, _linkingOffset)
    }
  }

  function tail(LinkedList s) internal pure returns (bytes32 elemPtr) {
    assembly ("memory-safe") {
      elemPtr := shr(176, shl(160, s))
    }
  }

  function head(LinkedList s) internal pure returns (bytes32 elemPtr) {
    assembly ("memory-safe") {
      elemPtr := shr(176, shl(80, s))
    }
  }

  function linkingOffset(LinkedList s) internal pure returns (uint80 offset) {
    assembly ("memory-safe") {
      offset := shr(176, s)
    }
  }

  function set_head(LinkedList self, bytes32 element) internal pure returns (LinkedList s) {
    assembly ("memory-safe") {
      s := or(and(self, HEAD_MASK), shl(96, element))
    }
  }

  // manually links one element to another
  function set_link(
    LinkedList self,
    bytes32 prevElem,
    bytes32 nextElem
  ) internal pure {
    assembly ("memory-safe") {
      // store the new element as the `next` ptr for the tail
      mstore(
        add(
          prevElem, // get the tail ptr
          shr(176, self) // add the offset size to get `next`
        ),
        nextElem
      )
    }
  }

  function push_and_link(LinkedList self, bytes32 element) internal pure returns (LinkedList s) {
    assembly ("memory-safe") {
      switch gt(shr(176, shl(80, self)), 0)
      case 1 {
        // store the new element as the `next` ptr for the tail
        mstore(
          add(
            shr(176, shl(160, self)), // get the tail ptr
            shr(176, self) // add the offset size to get `next`
          ),
          element
        )

        // update the tail ptr
        s := or(and(self, TAIL_MASK), shl(16, element))
      }
      default {
        // no head, set element as head and tail
        s := or(or(self, shl(96, element)), shl(16, element))
      }
    }
  }

  function next(LinkedList self, bytes32 element) internal pure returns (bool exists, bytes32 elem) {
    assembly ("memory-safe") {
      elem := mload(add(element, shr(176, self)))
      exists := gt(elem, 0x00)
    }
  }
}

enum QueryType {
  Has,
  Not,
  HasValue,
  NotValue,
  ProxyRead,
  ProxyExpand
}

// For ProxyRead and ProxyExpand QueryFragments:
// - component must be a component whose raw value decodes to a single uint256
// - value must decode to a single uint256 represents the proxy depth
struct QueryFragment {
  QueryType queryType;
  IComponent component;
  bytes value;
}

interface IUint256Component is IComponent {
  function set(uint256 entity, uint256 value) external;

  function getValue(uint256 entity) external view returns (uint256);

  function getEntitiesWithValue(uint256 value) external view returns (uint256[] memory);
}

// For ProxyRead and ProxyExpand QueryFragments:
// - component must be a component whose raw value decodes to a single uint256
// - value must decode to a single uint256 represents the proxy depth
struct WorldQueryFragment {
  QueryType queryType;
  uint256 componentId;
  bytes value;
}

interface IWorld {
  function components() external view returns (IUint256Component);

  function systems() external view returns (IUint256Component);

  function registerComponent(address componentAddr, uint256 id) external;

  function getComponent(uint256 id) external view returns (address);

  function getComponentIdFromAddress(address componentAddr) external view returns (uint256);

  function registerSystem(address systemAddr, uint256 id) external;

  function registerComponentValueSet(
    address component,
    uint256 entity,
    bytes calldata data
  ) external;

  function registerComponentValueSet(uint256 entity, bytes calldata data) external;

  function registerComponentValueRemoved(address component, uint256 entity) external;

  function registerComponentValueRemoved(uint256 entity) external;

  function getNumEntities() external view returns (uint256);

  function hasEntity(uint256 entity) external view returns (bool);

  function getUniqueEntityId() external view returns (uint256);

  function query(WorldQueryFragment[] calldata worldQueryFragments) external view returns (uint256[] memory);

  function init() external;
}

/**
 * @title Contract ownership standard interface
 * @dev see https://eips.ethereum.org/EIPS/eip-173
 */
interface IERC173 is IERC173Internal {
  /**
   * @notice get the ERC173 contract owner
   * @return conrtact owner
   */
  function owner() external view returns (address);

  /**
   * @notice transfer contract ownership to new account
   * @param account address of new owner
   */
  function transferOwnership(address account) external;
}

interface IOwnable is IERC173 {}

/**
 * @title utility functions for uint256 operations
 * @dev derived from https://github.com/OpenZeppelin/openzeppelin-contracts/ (MIT license)
 */
library UintUtils {
  error UintUtils__InsufficientHexLength();

  bytes16 private constant HEX_SYMBOLS = "0123456789abcdef";

  function add(uint256 a, int256 b) internal pure returns (uint256) {
    return b < 0 ? sub(a, -b) : a + uint256(b);
  }

  function sub(uint256 a, int256 b) internal pure returns (uint256) {
    return b < 0 ? add(a, -b) : a - uint256(b);
  }

  function toString(uint256 value) internal pure returns (string memory) {
    if (value == 0) {
      return "0";
    }

    uint256 temp = value;
    uint256 digits;

    while (temp != 0) {
      digits++;
      temp /= 10;
    }

    bytes memory buffer = new bytes(digits);

    while (value != 0) {
      digits -= 1;
      buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
      value /= 10;
    }

    return string(buffer);
  }

  function toHexString(uint256 value) internal pure returns (string memory) {
    if (value == 0) {
      return "0x00";
    }

    uint256 length = 0;

    for (uint256 temp = value; temp != 0; temp >>= 8) {
      unchecked {
        length++;
      }
    }

    return toHexString(value, length);
  }

  function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
    bytes memory buffer = new bytes(2 * length + 2);
    buffer[0] = "0";
    buffer[1] = "x";

    unchecked {
      for (uint256 i = 2 * length + 1; i > 1; --i) {
        buffer[i] = HEX_SYMBOLS[value & 0xf];
        value >>= 4;
      }
    }

    if (value != 0) revert UintUtils__InsufficientHexLength();

    return string(buffer);
  }
}

library AddressUtils {
  using UintUtils for uint256;

  error AddressUtils__InsufficientBalance();
  error AddressUtils__NotContract();
  error AddressUtils__SendValueFailed();

  function toString(address account) internal pure returns (string memory) {
    return uint256(uint160(account)).toHexString(20);
  }

  function isContract(address account) internal view returns (bool) {
    uint256 size;
    assembly {
      size := extcodesize(account)
    }
    return size > 0;
  }

  function sendValue(address payable account, uint256 amount) internal {
    (bool success, ) = account.call{ value: amount }("");
    if (!success) revert AddressUtils__SendValueFailed();
  }

  function functionCall(address target, bytes memory data) internal returns (bytes memory) {
    return functionCall(target, data, "AddressUtils: failed low-level call");
  }

  function functionCall(
    address target,
    bytes memory data,
    string memory error
  ) internal returns (bytes memory) {
    return _functionCallWithValue(target, data, 0, error);
  }

  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value
  ) internal returns (bytes memory) {
    return functionCallWithValue(target, data, value, "AddressUtils: failed low-level call with value");
  }

  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value,
    string memory error
  ) internal returns (bytes memory) {
    if (value > address(this).balance) revert AddressUtils__InsufficientBalance();
    return _functionCallWithValue(target, data, value, error);
  }

  /**
   * @notice execute arbitrary external call with limited gas usage and amount of copied return data
   * @dev derived from https://github.com/nomad-xyz/ExcessivelySafeCall (MIT License)
   * @param target recipient of call
   * @param gasAmount gas allowance for call
   * @param value native token value to include in call
   * @param maxCopy maximum number of bytes to copy from return data
   * @param data encoded call data
   * @return success whether call is successful
   * @return returnData copied return data
   */
  function excessivelySafeCall(
    address target,
    uint256 gasAmount,
    uint256 value,
    uint16 maxCopy,
    bytes memory data
  ) internal returns (bool success, bytes memory returnData) {
    returnData = new bytes(maxCopy);

    assembly {
      // execute external call via assembly to avoid automatic copying of return data
      success := call(gasAmount, target, value, add(data, 0x20), mload(data), 0, 0)

      // determine whether to limit amount of data to copy
      let toCopy := returndatasize()

      if gt(toCopy, maxCopy) {
        toCopy := maxCopy
      }

      // store the length of the copied bytes
      mstore(returnData, toCopy)

      // copy the bytes from returndata[0:toCopy]
      returndatacopy(add(returnData, 0x20), 0, toCopy)
    }
  }

  function _functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value,
    string memory error
  ) private returns (bytes memory) {
    if (!isContract(target)) revert AddressUtils__NotContract();

    (bool success, bytes memory returnData) = target.call{ value: value }(data);

    if (success) {
      return returnData;
    } else if (returnData.length > 0) {
      assembly {
        let returnData_size := mload(returnData)
        revert(add(32, returnData), returnData_size)
      }
    } else {
      revert(error);
    }
  }
}

interface IOwnableInternal is IERC173Internal {
  error Ownable__NotOwner();
  error Ownable__NotTransitiveOwner();
}

library OwnableStorage {
  struct Layout {
    address owner;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("solidstate.contracts.storage.Ownable");

  function layout() internal pure returns (Layout storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
}

abstract contract OwnableInternal is IOwnableInternal {
  using AddressUtils for address;

  modifier onlyOwner() {
    if (msg.sender != _owner()) revert Ownable__NotOwner();
    _;
  }

  modifier onlyTransitiveOwner() {
    if (msg.sender != _transitiveOwner()) revert Ownable__NotTransitiveOwner();
    _;
  }

  function _owner() internal view virtual returns (address) {
    return OwnableStorage.layout().owner;
  }

  function _transitiveOwner() internal view virtual returns (address owner) {
    owner = _owner();

    while (owner.isContract()) {
      try IERC173(owner).owner() returns (address transitiveOwner) {
        owner = transitiveOwner;
      } catch {
        break;
      }
    }
  }

  function _transferOwnership(address account) internal virtual {
    _setOwner(account);
  }

  function _setOwner(address account) internal virtual {
    OwnableStorage.Layout storage l = OwnableStorage.layout();
    emit OwnershipTransferred(l.owner, account);
    l.owner = account;
  }
}

/**
 * @title Ownership access control based on ERC173
 */
abstract contract Ownable is IOwnable, OwnableInternal {
  /**
   * @inheritdoc IERC173
   */
  function owner() public view virtual returns (address) {
    return _owner();
  }

  /**
   * @inheritdoc IERC173
   */
  function transferOwnership(address account) public virtual onlyOwner {
    _transferOwnership(account);
  }
}

library OwnableStorage {
  struct Layout {
    address owner;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("solidstate.contracts.storage.Ownable");

  function layout() internal pure returns (Layout storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
}

/**
 * IERC173 implementation
 */
contract Ownable is Ownable {
  constructor() {
    // Initialize owner (SolidState has no constructors)
    _setOwner(msg.sender);
  }
}

/**
 * System base contract
 */
abstract contract System is ISystem, Ownable {
  IUint256Component components;
  IWorld world;

  constructor(IWorld _world, address _components) {
    components = _components == address(0) ? _world.components() : IUint256Component(_components);
    world = _world;
  }
}

// ESP core

interface ISignalRouterSystem {
  function viewStreamCall() external view returns (uint256);

  function endCall() external;
}

interface IMemberRegistrySystem {
  function executeTyped(uint256, address) external returns (bool);
}

// MUD Core

// ESP Core

interface IStreamOwnerRegistry {
  function validOwner(uint256, address) external view returns (bool);
}

/**
@notice StreamOwnerRegistry maintains mappings of valid owners for particular streams in the context of a SignalRouterSystem
@notice Only owners registered here for particular streams can mutate StreamMemberIndexComponent, TopLevelSystemIndexComponent, and StreamSystemIndexComponent values
@notice Lazily built this not in soleclib systems/component compliance: to be upgraded to a system/component architecture at a later date
@dev StreamMemberIndexComponent, TopLevelSystemIndexComponent, and StreamSystemIndexComponent registered to this registry have their owners set to this contract. Therefore, all mutating calls to them must be routed through this registry.
 */

contract StreamOwnerRegistry is IStreamOwnerRegistry {
  mapping(uint256 => mapping(address => bool)) users;
  mapping(uint256 => bool) registeredStreams;

  address immutable router;
  address immutable SMIC;
  address immutable TLSIC;
  address immutable SSIC;

  constructor(
    address _router,
    address _SMIC,
    address _TLSIC,
    address _SSIC
  ) {
    router = _router;
    SMIC = _SMIC;
    TLSIC = _TLSIC;
    SSIC = _SSIC;
  }

  function streamRegister(uint256 _stream, address[] memory _users) public {
    if (registeredStreams[_stream]) {
      require(users[_stream][msg.sender], "Caller not valid on this stream");
      if (_users.length > 0) {
        for (uint256 i = 0; i > _users.length; i++) {
          users[_stream][_users[i]] = true;
        }
      }
    } else {
      registeredStreams[_stream] = true;
      users[_stream][msg.sender] = true;
      if (_users.length > 0) {
        for (uint256 i = 0; i > _users.length; i++) {
          users[_stream][_users[i]] = true;
        }
      }
    }
  }

  function validOwner(uint256 _stream, address _user) public view returns (bool) {
    return users[_stream][_user];
  }

  modifier onlyStreamOwner(uint256 _stream) {
    require(validOwner(_stream, msg.sender));
    _;
  }

  function mutateMemberRegistrySystem(uint256 _stream, address _system) public onlyStreamOwner(_stream) {
    IComponent(SMIC).set(_stream, abi.encode(_system));
  }

  /**
    @notice A stream may have one or more TopLevelSystems available to call
    @notice For a TopLevelSystem to mutate state, it must also be registered as a StreamSystem
    @param _add boolean for adding (true) or removing (false) a top level system from a stream
     */
  function addOrRemoveTopLevelSystem(
    uint256 _stream,
    address _system,
    bool _add
  ) public onlyStreamOwner(_stream) {
    bytes memory boolUpdate = abi.encodePacked(_add);
    IComponent(TLSIC).set(uint256(keccak256(abi.encode(_stream, _system))), boolUpdate);
  }

  /**
    @notice A stream may have one or more StreamSystems available permissioned for component state updates
    @param _add boolean for adding (true) or removing (false) a top level system from a stream
     */
  function addOrRemoveStreamSystem(
    uint256 _stream,
    address _system,
    bool _add
  ) public onlyStreamOwner(_stream) {
    bytes memory boolUpdate = abi.encodePacked(_add);
    IComponent(SSIC).set(uint256(keccak256(abi.encode(_stream, _system))), boolUpdate);
  }
}

// MUD Core

/**
 * Set of unique uint256
 */
contract Set is Ownable {
  uint256[] internal items;
  mapping(uint256 => uint256) internal itemToIndex;

  function add(uint256 item) public onlyOwner {
    if (has(item)) return;

    itemToIndex[item] = items.length;
    items.push(item);
  }

  function remove(uint256 item) public onlyOwner {
    if (!has(item)) return;

    // Copy the last item to the given item's index
    items[itemToIndex[item]] = items[items.length - 1];

    // Update the moved item's stored index to the new index
    itemToIndex[items[itemToIndex[item]]] = itemToIndex[item];

    // Remove the given item's stored index
    delete itemToIndex[item];

    // Remove the last item
    items.pop();
  }

  function getIndex(uint256 item) public view returns (bool, uint256) {
    if (!has(item)) return (false, 0);

    return (true, itemToIndex[item]);
  }

  function has(uint256 item) public view returns (bool) {
    if (items.length == 0) return false;
    if (itemToIndex[item] == 0) return items[0] == item;
    return itemToIndex[item] != 0;
  }

  function getItems() public view returns (uint256[] memory) {
    return items;
  }

  function size() public view returns (uint256) {
    return items.length;
  }
}

/**
 * Key value store with uint256 key and uint256 Set value
 */
contract MapSet is Ownable {
  mapping(uint256 => uint256[]) internal items;
  mapping(uint256 => mapping(uint256 => uint256)) internal itemToIndex;

  function add(uint256 setKey, uint256 item) public onlyOwner {
    if (has(setKey, item)) return;

    itemToIndex[setKey][item] = items[setKey].length;
    items[setKey].push(item);
  }

  function remove(uint256 setKey, uint256 item) public onlyOwner {
    if (!has(setKey, item)) return;

    // Copy the last item to the given item's index
    items[setKey][itemToIndex[setKey][item]] = items[setKey][items[setKey].length - 1];

    // Update the moved item's stored index to the new index
    itemToIndex[setKey][items[setKey][itemToIndex[setKey][item]]] = itemToIndex[setKey][item];

    // Remove the given item's stored index
    delete itemToIndex[setKey][item];

    // Remove the last item
    items[setKey].pop();
  }

  function has(uint256 setKey, uint256 item) public view returns (bool) {
    if (items[setKey].length == 0) return false;
    if (itemToIndex[setKey][item] == 0) return items[setKey][0] == item;
    return itemToIndex[setKey][item] != 0;
  }

  function getItems(uint256 setKey) public view returns (uint256[] memory) {
    return items[setKey];
  }

  function size(uint256 setKey) public view returns (uint256) {
    return items[setKey].length;
  }
}

library OwnableWritableStorage {
  struct Layout {
    /** Addresses with write access */
    mapping(address => bool) writeAccess;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("solecs.contracts.storage.OwnableWritable");

  function layout() internal pure returns (Layout storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
}

/**
 * Ownable with authorized writers
 */
abstract contract OwnableWritable is IOwnableWritable, Ownable {
  error OwnableWritable__NotWriter();

  /** Whether given operator has write access */
  function writeAccess(address operator) public view returns (bool) {
    return OwnableWritableStorage.layout().writeAccess[operator] || operator == owner();
  }

  /** Revert if caller does not have write access to this component */
  modifier onlyWriter() {
    if (!writeAccess(msg.sender)) {
      revert OwnableWritable__NotWriter();
    }
    _;
  }

  /**
   * Grant write access to the given address.
   * Can only be called by the owner.
   * @param writer Address to grant write access to.
   */
  function authorizeWriter(address writer) public onlyOwner {
    OwnableWritableStorage.layout().writeAccess[writer] = true;
  }

  /**
   * Revoke write access from the given address.
   * Can only be called by the owner.
   * @param writer Address to revoke write access.
   */
  function unauthorizeWriter(address writer) public onlyOwner {
    delete OwnableWritableStorage.layout().writeAccess[writer];
  }
}

/**
 * Components are a key-value store from entity id to component value.
 * They are registered in the World and register updates to their state in the World.
 * They have an owner, who can grant write access to more addresses.
 * (Systems that want to write to a component need to be given write access first.)
 * Everyone has read access.
 */
abstract contract BareComponent is IComponent, OwnableWritable {
  error BareComponent__NotImplemented();

  /** Reference to the World contract this component is registered in */
  address public world;

  /** Mapping from entity id to value in this component */
  mapping(uint256 => bytes) internal entityToValue;

  /** Public identifier of this component */
  uint256 public id;

  constructor(address _world, uint256 _id) {
    id = _id;
    if (_world != address(0)) registerWorld(_world);
  }

  /**
   * Register this component in the given world.
   * @param _world Address of the World contract.
   */
  function registerWorld(address _world) public onlyOwner {
    world = _world;
    IWorld(world).registerComponent(address(this), id);
  }

  /**
   * Set the given component value for the given entity.
   * Registers the update in the World contract.
   * Can only be called by addresses with write access to this component.
   * @param entity Entity to set the value for.
   * @param value Value to set for the given entity.
   */
  function set(uint256 entity, bytes memory value) public override onlyWriter {
    _set(entity, value);
  }

  /**
   * Remove the given entity from this component.
   * Registers the update in the World contract.
   * Can only be called by addresses with write access to this component.
   * @param entity Entity to remove from this component.
   */
  function remove(uint256 entity) public override onlyWriter {
    _remove(entity);
  }

  /**
   * Check whether the given entity has a value in this component.
   * @param entity Entity to check whether it has a value in this component for.
   */
  function has(uint256 entity) public view virtual override returns (bool) {
    return entityToValue[entity].length != 0;
  }

  /**
   * Get the raw (abi-encoded) value of the given entity in this component.
   * @param entity Entity to get the raw value in this component for.
   */
  function getRawValue(uint256 entity) public view virtual override returns (bytes memory) {
    // Return the entity's component value
    return entityToValue[entity];
  }

  /** Not implemented in BareComponent */
  function getEntities() public view virtual override returns (uint256[] memory) {
    revert BareComponent__NotImplemented();
  }

  /** Not implemented in BareComponent */
  function getEntitiesWithValue(bytes memory) public view virtual override returns (uint256[] memory) {
    revert BareComponent__NotImplemented();
  }

  /** Not implemented in BareComponent */
  function registerIndexer(address) external virtual override {
    revert BareComponent__NotImplemented();
  }

  /**
   * Set the given component value for the given entity.
   * Registers the update in the World contract.
   * Can only be called internally (by the component or contracts deriving from it),
   * without requiring explicit write access.
   * @param entity Entity to set the value for.
   * @param value Value to set for the given entity.
   */
  function _set(uint256 entity, bytes memory value) internal virtual {
    // Store the entity's value;
    entityToValue[entity] = value;

    // Emit global event
    IWorld(world).registerComponentValueSet(entity, value);
  }

  /**
   * Remove the given entity from this component.
   * Registers the update in the World contract.
   * Can only be called internally (by the component or contracts deriving from it),
   * without requiring explicit write access.
   * @param entity Entity to remove from this component.
   */
  function _remove(uint256 entity) internal virtual {
    // Remove the entity from the mapping
    delete entityToValue[entity];

    // Emit global event
    IWorld(world).registerComponentValueRemoved(entity);
  }
}

/**
@notice A mapping of uint256 streamIDs => address of a MemberRegistrySystem 
@notice The MemberRegistrySystem takes care of all logic for determining if a particular user is valid
 */

contract StreamMemberIndexComponent is BareComponent {
  constructor(address world, uint256 id) BareComponent(world, id) {}

  function getValue(uint256 entity) public view returns (address) {
    bytes memory rawValue = getRawValue(entity);
    if (rawValue.length > 0) {
      return abi.decode(rawValue, (address));
    } else {
      return address(0);
    }
  }

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](1);
    values = new LibTypes.SchemaValue[](1);

    keys[0] = "memberRegistrySystem";
    values[0] = LibTypes.SchemaValue.ADDRESS;
  }
}

// MUD Core

// ESP Core

/** Expects packed encoding */
function decodeBool(bytes memory _data) pure returns (bool b) {
  assembly {
    // Load the length of data (first 32 bytes)
    let len := mload(_data)
    // Load the data after 32 bytes, so add 0x20
    b := mload(add(_data, 0x20))
  }
}

contract TopLevelSystemIndexComponent is BareComponent {
  constructor(address world, uint256 id) BareComponent(world, id) {}

  function getValue(uint256 entity) public view returns (bool) {
    bytes memory rawValue = getRawValue(entity);
    if (rawValue.length > 0) {
      return decodeBool(rawValue);
    } else {
      return false;
    }
  }

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](1);
    values = new LibTypes.SchemaValue[](1);

    keys[0] = "topLevelSystemAddress";
    values[0] = LibTypes.SchemaValue.ADDRESS;
  }
}

// MUD Core

// ESP Core

contract StreamSystemIndexComponent is BareComponent {
  constructor(address world, uint256 id) BareComponent(world, id) {}

  function getValue(uint256 entity) public view returns (bool) {
    bytes memory rawValue = getRawValue(entity);
    if (rawValue.length > 0) {
      return decodeBool(rawValue);
    } else {
      return false;
    }
  }

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](1);
    values = new LibTypes.SchemaValue[](1);

    keys[0] = "streamSystem";
    values[0] = LibTypes.SchemaValue.ADDRESS;
  }
}

contract SignalRouterSystem is System, ISignalRouterSystem {
  // set these upon Router deployment
  StreamOwnerRegistry public RouterSOR;
  StreamMemberIndexComponent public RouterSMIC;
  TopLevelSystemIndexComponent public RouterTLSIC;
  StreamSystemIndexComponent public RouterSSIC;

  address public immutable _this;

  address public immutable _worldAddress;

  /**@notice _streamCall preserves the integrity of the _stream ID for systems requesting state updates via reentrancy within a single call chain */
  uint256 public _streamCall;

  uint256 constant _SMIC_ID = uint256(keccak256("ESP.component.StreamMemberIndexComponent"));
  uint256 constant _TLSIC_ID = uint256(keccak256("ESP.component.TopLevelSystemIndexComponent"));
  uint256 constant _SSIC_ID = uint256(keccak256("ESP.component.StreamSystemIndexComponent"));

  constructor(IWorld _world) System(_world, address(0)) {
    _this = address(this);
    _worldAddress = address(_world);
    // Deploys necessary registry & indeces linked to this router
    RouterSMIC = new StreamMemberIndexComponent(_worldAddress, _SMIC_ID);
    RouterTLSIC = new TopLevelSystemIndexComponent(_worldAddress, _TLSIC_ID);
    RouterSSIC = new StreamSystemIndexComponent(_worldAddress, _SSIC_ID);
    RouterSOR = new StreamOwnerRegistry(_this, address(RouterSMIC), address(RouterTLSIC), address(RouterSSIC));
    // Update stream abstraction component owners to the stream registry
    RouterSMIC.authorizeWriter(address(RouterSOR));
    RouterTLSIC.authorizeWriter(address(RouterSOR));
    RouterSSIC.authorizeWriter(address(RouterSOR));
    RouterSSIC.unauthorizeWriter(_this);
    RouterTLSIC.unauthorizeWriter(_this);
    RouterSMIC.unauthorizeWriter(_this);
  }

  /**
    @param arguments formatted as (uint256 _stream, address _system, bytes _arguments)
    @param _stream is the unique streamID
    @param _system is the address of the system to execute in this call
    @param _arguments are arguments to be passed along to the system call
    @param _component is the address of the component to update, sent by a system requesting a state mutation
     */

  /**
     @dev possibly replace 'hard contract calls' to stream abstraction contract with interface calls to save on gas
      */

  function execute(bytes memory arguments) public override returns (bytes memory) {
    /**
        @notice _reentrancyCheck helps to determine if a user is the initial caller. This prevents malicious systems calling the router directly to mutate the state for a previously logged _streamCall. Should ensure that all execute calls must initiate from an end user calling this router - not from a user calling a system directly
        */

    if (tx.origin == msg.sender) {
      // executes if the caller is an account
      // currently prevents external contract entities / abstractions from calling this contract
      (uint256 _stream, address _system, bytes memory _arguments) = abi.decode(arguments, (uint256, address, bytes));

      // Checks is user is valid for stream
      address MemberRegistrySystemAddress = RouterSMIC.getValue(_stream);
      require(MemberRegistrySystemAddress != address(0), "No MemberRegistrySystem found at address");
      require(IMemberRegistrySystem(MemberRegistrySystemAddress).executeTyped(_stream, msg.sender), "Not valid member");

      // Checks if system to call is valid for stream
      require(
        RouterTLSIC.getValue(uint256(keccak256(abi.encode(_stream, _system)))),
        "System not valid at top level for stream"
      );

      // Reentrancy check
      _streamCall = _stream;

      // Calls valid StreamSystem
      ISystem(_system).execute(_arguments);
    } else {
      // executes if the caller is another contract

      (address _component, bytes memory keys, bytes memory value) = abi.decode(arguments, (address, bytes, bytes));

      // Checks if calling system is registered for state updates for this stream
      require(RouterSSIC.getValue(uint256(keccak256(abi.encode(_streamCall, msg.sender)))));

      // Unique key to update will always be a hash of the lookup keys and the streamID, which is stored in _streamCall upon initial Router call
      // State management using hashed key values is not ideal, and should be upgraded pending fixed implementation in MUD framework being dealt with here: https://github.com/latticexyz/mud/issues/347
      IComponent(_component).set(uint256(keccak256(abi.encode(_streamCall, keys))), value);
    }
  }

  /**
    @dev allows access to current _streamCall in downstream systems
     */
  function viewStreamCall() public view returns (uint256) {
    return _streamCall;
  }

  /**
  @dev Prevents malicious systems directly calling router to update another stream's state
  @dev Your systems MUST implement this function after their last state update, or risk malicious state mutations!
  @dev For this reason, stream ID 0 is always unsafe and should never be used
  @dev Add check to make sure that streamID 0 can never be logged or called
   */
  function endCall() public {
    require(RouterSSIC.getValue(uint256(keccak256(abi.encode(_streamCall, msg.sender)))));
    delete _streamCall;
  }
}
