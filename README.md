# LibreDólar ($LD)

**LibreDólar** es un token digital desarrollado en la red Polygon, basado en el estándar ERC20, con funcionalidades extendidas como quema de tokens (`burn`), comisión configurable en transferencias, y control de propiedad. Está diseñado como un activo útil para pagos, recompensas y economía descentralizada.

---

## 🔗 Información del Token

- **Nombre:** LibreDólar  
- **Símbolo:** $LD  
- **Decimales:** 18  
- **Supply total:** 1.000.000.000 $LD  
- **Red:** Polygon  
- **Estándar:** ERC20  
- **Dirección del contrato:** [`0x7f4DD9711d7f72163d9E75877A30574D7aEb4bae`](https://polygonscan.com/token/0x7f4DD9711d7f72163d9E75877A30574D7aEb4bae)

---

## 📄 Características del Contrato

- ✅ Estándar ERC20 completo
- 🔥 Soporte para `burn` y `burnFrom`
- 💸 Comisión opcional configurable en transferencias
- 🔐 Gestión de propietario (`owner`)
- 🛠️ Funciones de administración accesibles solo por el owner

---

## ⚙️ Funcionalidades Administrativas

- `setFeeCollector(address)` – Define la dirección que recibe las comisiones.
- `setFeePercent(uint256)` – Ajusta el porcentaje de comisión (máx. 10%).
- `setFeeActive(bool)` – Activa o desactiva la comisión.
- `transferOwnership(address)` – Transfiere la propiedad del contrato.

---

## 🧾 Verificación

- El contrato está verificado en Polygonscan:  
  👉 [https://polygonscan.com/token/0x7f4DD9711d7f72163d9E75877A30574D7aEb4bae](https://polygonscan.com/token/0x7f4DD9711d7f72163d9E75877A30574D7aEb4bae)

---

## 📦 Estructura

Este repositorio contiene el archivo principal del contrato inteligente:


