# Скрипты для тестирования

Разнообразные скрипты для Truffle используемые при тестировании.

## Синопсис

```
truffle exec scripts/send-eth.js
```

## Запуск

`./runweb3.sh` `scripts/`<*скрипт*>`.js`

где:

*скрипт* - имя скрипта.

## Скрипты

### show-accounts

Выводит список аккаунтов и их баланс.

```
(0) 0x58bb9e15db607bcf3d1a9a78a5a71cb45adf18d5 999999999.6182108
(1) 0x77d2303f7ebb077c5a149ebd4095608ad5c94aad 1000000000
(2) 0x664719842e5ffd0d74b558717dca244e41a0d2d0 1000000000
(3) 0x8dcf7e9b8106a8b2fb75f6061d94242cf036cc50 100
(4) 0xee787b18ec4a584dd1f2d3eeb928949b76c8e374 100
(5) 0xf7b11cc3ee8d670f5aeac722f40a1ad8b5438447 100
(6) 0xd766d544f84fbd79986da19ae994652f095ddb2d 100
(7) 0xc6b6573da82565bb6bfe70486e7c80362b762502 100
```

### send-eth

Отправляет Ethereum. Выводит чек.

#### Аргументы

*адрес_получателя* - Ethereum-адрес в виде `0x00dEAd00BabE...cafE` или индекс в массиве аккаунтов.

*сумма* - сумма в ETH. float.

*адрес_отправителя* - Ethereum-адрес в виде `0x00dEAd00BabE...cafE` или индекс в массиве аккаунтов. Опциональный. По умолчанию использует `defaultAccount` или аккаунт с индексом `0`.


### add-to-whitelist

Добавляет аккаунт в `Whitelist`.

#### Аргументы

*адрес* - Ethereum-адрес в виде `0x00dEAd00BabE...cafE` или индекс в массиве аккаунтов

### remove-from-whitelist

Удаляет адрес из `Whitelist`.

#### Аргументы

*адрес* - Ethereum-адрес в виде `0x00dEAd00BabE...cafE` или индекс в массиве аккаунтов

### check-whitelist

Выводит список всех аккаунтов и их наличие в `Whitelist`.

```
(0) 0x58bb9e15db607bcf3d1a9a78a5a71cb45adf18d5 false
(1) 0x77d2303f7ebb077c5a149ebd4095608ad5c94aad true
(2) 0x664719842e5ffd0d74b558717dca244e41a0d2d0 true
(3) 0x8dcf7e9b8106a8b2fb75f6061d94242cf036cc50 true
(4) 0xee787b18ec4a584dd1f2d3eeb928949b76c8e374 true
(5) 0xf7b11cc3ee8d670f5aeac722f40a1ad8b5438447 true
(6) 0xd766d544f84fbd79986da19ae994652f095ddb2d false
(7) 0xc6b6573da82565bb6bfe70486e7c80362b762502 false
```

### update-ether-price

Устанавливает курс USD/ETH.

#### Аргументы

*etherPrice* - курс USD/ETH округленный до ближайшего целого. uint8.

### release-tokens

Разрешает перевод токенов. Предварительно требует вызова `change-ownership-of-token`.

### give-tokens

Начисляет токены на адрес.

#### Аргументы

*адрес* - адрес получателя токенов в виде `0x00dEAd00BabE...cafE` или индекс в массиве аккаунтов.

*сумма* - сумма в токенах. float.

### balance-of

Получает баланс в токенах.

#### Аргументы

*адрес* - адрес виде `0x00dEAd00BabE...cafE` или индекс в массиве аккаунтов.

### change-ownership-of-token

Изменяет владельца контракта `WonoToken` на контракт `Crowdsale`. Необходимо для корректной работы `Crowdsale`.
