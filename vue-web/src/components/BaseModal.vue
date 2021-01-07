<template>
  <div id="open-modal" class="modal-window">
    <div>
        <slot></slot>
    </div>
  </div>
</template>

<script>
export default {
  name: 'BaseModal'
}
</script>

<style>

.modal-window {
  position: fixed;
  background-color: rgba(0, 0, 0, 0.80);
  top: 0;
  right: 0;
  bottom: 0;
  left: 0;
  z-index: 999;
  pointer-events: auto;
  transition: all 0.3s;
}
.modal-window > div {
  width: 800px;
  position: absolute;
  top: 60%;
  left: 50%;
  transform: translate(-50%, -50%);
  padding: 2em;
  text-align: center;
  background: #fff;
}
.modal-window header {
  font-weight: bold;
}
.modal-window h1 {
  font-size: 150%;
  margin: 0 0 15px;
}
.modal-close {
  color: #aaa;
  line-height: 50px;
  font-size: 80%;
  position: absolute;
  right: 0;
  text-align: center;
  top: 0;
  width: 70px;
  text-decoration: none;
}
.modal-close:hover {
  color: black;
}
/* Demo Styles */
.container {
  display: grid;
  justify-content: center;
  align-items: center;
  height: 100vh;
}
.modal-window div:not(:last-of-type) {
  margin-bottom: 15px;
}
small {
  color: #aaa;
}

.btn i {
  padding-right: 0.3em;
}

</style>
