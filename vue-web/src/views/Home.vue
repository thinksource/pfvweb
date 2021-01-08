<template>
  <div class="home">
    <UserTable table_head="List Users" />
  </div>
</template>

<script lang="ts">
import { Options, Vue } from 'vue-class-component'
// import HelloWorld from '@/components/HelloWorld.vue' // @ is an alias to /src
import UserTable from '@/components/UserTable.vue'
@Options({
  components: {
    UserTable
  }
})
export default class Home extends Vue {}
</script>
