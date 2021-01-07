<template>
  <div class="home">
    <img alt="Vue logo" src="../assets/logo.png">
    <UserTable table_head="List Users" />
  </div>
</template>

<script lang="ts">
import { defineComponent, inject, reactive, toRefs } from 'vue'
// import HelloWorld from '@/components/HelloWorld.vue' // @ is an alias to /src
import UserTable from '@/components/UserTable.vue'
// import UserTable from '../components/UserTable.vue'

declare global {
  interface Window {
    '$': any;
  }
}

export default defineComponent({
  name: 'Home',
  components: {
    // HelloWorld,
    UserTable
  },
  setup () {
    const state = reactive({
      list_user: Array<{id: string, first_name: string, last_name: string, gender: string, email: string, telephone: string}>()
    })

    return { ...toRefs(state) }
  }
})
</script>
