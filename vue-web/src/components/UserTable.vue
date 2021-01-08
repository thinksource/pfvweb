<script lang="ts">
import { defineComponent, onBeforeMount, ref, reactive, toRefs } from 'vue'
import BaseModal from './BaseModal.vue'
import axios from 'axios'

function getDefaultPic (gender: string) {
  if (gender === 'female') {
    return 'http://localhost:5000/static/female.svg'
  } else if (gender === 'male') {
    return 'http://localhost:5000/static/male.svg'
  } else {
    return '#'
  }
}

interface UserData{
  id: string;
  first_name: string;
  last_name: string;
  gender: string;
  email: string;
  telephone: string;
}

export default defineComponent({
  name: 'UserTable',
  components: {
    BaseModal
  },
  props: {
    table_head: String
  },
  setup (props, context) {
    // const axios: any = inject('axios')
    const prePic = ref(null)
    const state = reactive({
      showModal: false,
      modalTitle: '',
      userFirstName: '',
      userLastName: '',
      userGender: '',
      userEmail: '',
      userTelephone: '',
      userId: '',
      loginEmail: '',
      loginId: -1,
      loginPic: '',
      loginPicUrl: '#',
      loginGender: '',
      operate: '',
      resMessage: '',
      list_user: new Array<UserData>(0)
    })

    const resetModal = () => {
      state.userFirstName = ''
      state.userLastName = ''
      state.userEmail = ''
      state.userTelephone = ''
      state.userId = ''
    }

    const createUser = () => {
      resetModal()
      state.showModal = true
      state.operate = 'add'
      state.modalTitle = 'Add now User'
    }
    const submitUser = async () => {
      const jsData = {
        first_name: state.userFirstName,
        last_name: state.userLastName,
        gender: state.userGender,
        email: state.userEmail,
        telephone: state.userTelephone
      }
      console.log(jsData)
      if (state.userId.length === 0) {
        const res = await axios.post('http://localhost:5000/api/create_user', jsData)
        if (res.status === 200) {
          resetModal()
          state.resMessage = res.data.messsage
        } else {
          state.resMessage = res.data.message
        }
        state.showModal = false
      } else {
        const res = await axios.post(`http://localhost:5000/api/edit_user/${state.userId}`, jsData)
        if (res.status === 200) {
          resetModal()
          state.resMessage = res.data.messsage
        } else {
          state.resMessage = res.data.message
        }
        state.showModal = false
      }
      list_user()
    }
    const loginAs = async (email: string) => {
      const prePic = document.getElementById('prePic')
      const res = await axios.post('http://localhost:5000/api/login', { email })
      console.log(res)
      if (res.status === 200) {
        state.loginEmail = res.data.email
        state.loginId = res.data.user_id
        state.loginPic = res.data.image_id
        const gender = res.data.gender
        state.loginGender = res.data.gender
        console.log(state)
        if (state.loginPic.length > 0) {
          state.loginPicUrl = `http://localhost:5000/api/image/${state.loginPic}/0`
        //   prePic?.setAttribute('src', `http://localhost:5000/api/image/${state.loginPic}/0`)
        } else {
          console.log(prePic)
          state.loginPicUrl = getDefaultPic(gender)
        //   prePic?.setAttribute('src', getDefaultPic(gender))
        }
        console.log(prePic?.getAttribute('src'))
      }
    }

    const editUser = async (index:number) => {
      state.showModal = true
      const u = state.list_user[index]
      state.modalTitle = `Edit user ${u.first_name} ${u.last_name}`
      if (u) {
        state.userId = u.id
        state.userFirstName = u.first_name
        state.userLastName = u.last_name
        state.userGender = u.gender
        state.userEmail = u.email
        state.userTelephone = u.telephone
      }
      list_user()
    }

    const preview = (e:InputEvent) => {
      const reader = new FileReader()
      const prePic = document.getElementById('prePic')
      const input = e.target as HTMLInputElement
      if (input && input.files && prePic) {
        reader.addEventListener('load', function () {
          prePic.setAttribute('src', reader.result as string)
        })
        reader.readAsDataURL(input.files[0])
      }
    }
    const submitImage = async () => {
      const formData = new FormData()
      const uploadFile = document.getElementById('uploadFile') as HTMLInputElement
      console.log(state.loginPic)
      if (uploadFile && uploadFile.files) {
        formData.append('image', uploadFile.files[0])
        formData.append('user_id', state.loginId.toString())
        console.log(state.loginPic)
        if (state.loginPic) {
          formData.append('loginPic', state.loginPic)
        }
        const res = await axios.post('http://localhost:5000/api/upload_image', formData, { headers: { 'Content-Type': 'multipart/form-data' } })
        if (res.status === 200) {
          console.log(res.data)
          list_user()
        }
      }
    }
    const deleteImage = async () => {
      const prePic = document.getElementById('prePic')
      if (state.loginPic) {
        const res = await axios.delete(`http://localhost:5000/api/delete_image/${state.loginPic}`)
        state.loginPic = ''
        if (res.status === 200) {
          prePic?.setAttribute('src', getDefaultPic(state.loginGender))
        }
      } else {
        prePic?.setAttribute('src', getDefaultPic(state.loginGender))
      }
    }

    const deleteUser = async (id:string, index:number) => {
      const res = await axios.delete(`http://localhost:5000/api/delete_user/${id}`)
      if (res.status === 200) {
        state.list_user.splice(index, 1)
        state.resMessage = res.data.message
      }
    }

    const list_user = () => {
      state.list_user = []
      axios.get('http://localhost:5000/api/list_user').then((res: any) => {
        for (const i of res.data) {
          console.log(i)
          state.list_user.push(i)
        }
      }).catch((e: any) => {
        console.log(e)
      })
    }

    onBeforeMount(() => {
      list_user()
    })
    return { ...toRefs(state), createUser, loginAs, preview, submitImage, deleteImage, submitUser, editUser, resetModal, deleteUser, prePic }
  }

})
</script>

<template>
  <div class="container">
    <div class="row">
      <h1>{{ table_head }}</h1>
    </div>
    <div class="row">
      <div v-if="resMessage" class="justify-content-end alert alert-primary">
        {{resMessage}}
      </div>
    </div>
    <div class="row">
      <div class="justify-content-end">
        <button type="button" class="btn btn-primary" @click="createUser">Add User</button>
      </div>
    </div>
    <div class="row">
      <div class="justify-content-end">
        You are login as: {{loginEmail}} (id: {{loginId}})
      </div>
    </div>
    <div class="" v-if="loginId>0">
      Upload Your Picture:
      <input id='uploadFile' type='file' @change="preview($event)"/><br/>
      <img id="prePic" :src="loginPicUrl" alt="your image" /><br/>
      <button class="btn btn-primary" @click='submitImage'>Upload Picture</button>
      <button class="btn btn-secondary" @click="deleteImage"> Delete Picture </button>
    </div>
    <div class="row">
      <div class="col"> thrumbnail</div>
      <div class="col">Name</div>
      <div class="col">email</div>
      <div class="col">gender</div>
      <div class="col">telephone</div>
      <div class="col">edit</div>
      <div class="col">delete</div>
      <div class="col"></div>

    </div>
      <div class="row align-items-center row-cols-8" v-for="(item, index) in list_user" :key="index">
        <div> <img :src="`http://localhost:5000/api/profile_image/${item.id}/${item.gender}?dummy=${Math.random()}`" alt="profile picture" width="40" height="40"></div>
        <div class="col">{{item.first_name}}.{{item.last_name}}</div>
        <div class="col">{{item.email}}</div>
        <div class="col">{{item.gender}}</div>
        <div class="col">{{item.telephone}}</div>
        <div class="col">
            <button  class="btn btn-primary" @click="editUser(index)">edit</button>
        </div>
        <div class="col">
          <button class="btn btn-danger" @click="deleteUser(item.id, index)">Delete</button>
        </div>
        <div class="col">
            <button @click ="loginAs(item.email)">Login as {{item.first_name}}.{{item.last_name}}</button>
        </div>

      </div>
  </div>
  <BaseModal v-if="showModal">
    <a href="#" title="Close" class="modal-close" @click="showModal=false">X</a>
    <H1>{{modalTitle}}</H1>
    <table>
      <tr>
        <td>First Name:</td>
        <td><input type="text" v-model="userFirstName"/></td>
      </tr>
      <tr>
        <td>Last Name:</td>
        <td><input type="text" v-model="userLastName"/></td>
      </tr>
      <tr>
        <td>Gender:</td>
        <td>
          <input type="radio" id="one" value="male" v-model="userGender" />
          <label for="one">Male</label>
          <br />
          <input type="radio" id="two" value="female" v-model="userGender" />
          <label for="two">Female</label>
        </td>
      </tr>
      <tr>
        <td>Email:</td>
        <td><input type="text" v-model="userEmail"/></td>
      </tr>
      <tr>
        <td>Telephone:</td>
        <td><input type="text" v-model="userTelephone"/></td>
      </tr>
      <tr>
        <td>Profile Image:</td>
        <td>
          The uploda image after you login as certain User at Main list
        </td>
      </tr>
    </table>

    <button class="btn btn-primary"  @click='submitUser()'>Submit</button>
    <button class="btn btn-secondary" @click='resetModal()'>Cancel</button>
  </BaseModal>
</template>

<style scoped>
table {
  margin:auto;
}
table > tr > td {
  text-align: left;
}
</style>
