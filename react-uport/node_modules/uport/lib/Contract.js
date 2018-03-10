'use strict';

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; };

function _toConsumableArray(arr) { if (Array.isArray(arr)) { for (var i = 0, arr2 = Array(arr.length); i < arr.length; i++) { arr2[i] = arr[i]; } return arr2; } else { return Array.from(arr); } }

var arrayContainsArray = require('ethjs-util').arrayContainsArray;

// A derivative work of Nick Dodson's eths-contract https://github.com/ethjs/ethjs-contract/blob/master/src/index.js

var hasTransactionObject = function hasTransactionObject(args) {
  var txObjectProperties = ['from', 'to', 'data', 'value', 'gasPrice', 'gas'];
  if ((typeof args === 'undefined' ? 'undefined' : _typeof(args)) === 'object' && Array.isArray(args) === true && args.length > 0) {
    if (_typeof(args[args.length - 1]) === 'object' && (Object.keys(args[args.length - 1]).length === 0 || arrayContainsArray(Object.keys(args[args.length - 1]), txObjectProperties, true))) {
      return true;
    }
  }

  return false;
};

var getCallableMethodsFromABI = function getCallableMethodsFromABI(contractABI) {
  return contractABI.filter(function (json) {
    return (json.type === 'function' || json.type === 'event') && json.name.length > 0;
  });
};

var encodeMethodReadable = function encodeMethodReadable(methodObject, methodArgs) {
  var dataString = methodObject.name + '(';

  for (var i = 0; i < methodObject.inputs.length; i++) {
    var input = methodObject.inputs[i];
    var argString = input.type + ' ';

    if (input.type === 'string') {
      argString += '\'' + methodArgs[i] + '\'';
    } else if (input.type === ('bytes32' || 'bytes')) {
      // TODO don't assume hex input? or throw error if not hex
      // argString += `0x${new Buffer(methodArgs[i], 'hex')}`
      argString += '' + methodArgs[i];
    } else {
      argString += '' + methodArgs[i];
    }

    dataString += argString;

    if (methodObject.inputs.length - 1 !== i) {
      dataString += ', ';
    }
  }
  return dataString += ')';
};

var ContractFactory = function ContractFactory(extend) {
  return function (contractABI) {
    var output = {};
    output.at = function atContract(address) {

      function Contract() {
        var self = this;
        self.abi = contractABI || [];
        self.address = address || '0x';

        getCallableMethodsFromABI(contractABI).forEach(function (methodObject) {
          self[methodObject.name] = function contractMethod() {

            if (methodObject.constant === true) {
              throw new Error('A call does not return the txobject, no transaction necessary.');
            }

            if (methodObject.type === 'event') {
              throw new Error('An event does not return the txobject, events not supported');
            }

            var providedTxObject = {};
            var methodArgs = [].slice.call(arguments);

            if (methodObject.type === 'function') {
              if (hasTransactionObject(methodArgs)) providedTxObject = methodArgs.pop();
              var methodTxObject = Object.assign({}, providedTxObject, {
                to: self.address
              });

              methodTxObject.function = encodeMethodReadable(methodObject, methodArgs);

              if (!extend) return methodTxObject;

              var extendArgs = methodArgs.slice(methodObject.inputs.length);
              return extend.apply(undefined, [methodTxObject].concat(_toConsumableArray(extendArgs)));
            }
          };
        });
      }

      return new Contract();
    };

    return output;
  };
};

var buildRequestURI = function buildRequestURI(txObject) {
  return 'me.uport:' + txObject.to + '?function=' + txObject.function;
};

var Contract = ContractFactory(buildRequestURI);

exports.ContractFactory = ContractFactory;
exports.Contract = Contract;