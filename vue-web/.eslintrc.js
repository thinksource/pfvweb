module.exports = {
    "env": {
        "es6": true,
        "node": true
    },
    "extends": [
        "plugin:vue/essential",
        "standard"
    ],
    "globals": {
        "Atomics": "readonly",
        "SharedArrayBuffer": "readonly"
    },
    "parserOptions": {
        "ecmaVersion": 2018,
        "parser": "@typescript-eslint/parser",
        "sourceType": "module"
    },
    "plugins": [
        "vue",
        "@typescript-eslint"
    ],
    "rules": {
        "camelcase": "off",
        "vue/no-multiple-template-root": 0
    }
};