<template>
    <div class="benefit-panel">
        <div class="benefit-description">
          <p class="benefit-content">成为社区贡献者</p>
        </div>
        <div class="benefit-add">
            <el-button type="primary" @click="addNav">+添加导航</el-button>
        </div>
        <add-nav-dialog :showDialog="showAddNavDialog"  @close="closeDialog"></add-nav-dialog>
    </div>
</template>

<script>
import Web3 from 'web3'
import Staker from '@/api/abi/Staker.json';
import addNavDialog from './addNavDialog.vue';
  export default {
  components: { addNavDialog },
  name: "BenefitPanel",
  data() {
    return {
      showAddNavDialog: false,
      stakerAddress: '0x3DAD3B10a77f4E0bA43c2FA79Cc48D5AB7B16F45'
    }
  },
  methods: {
    addNav() {
      this.getStakerStatus()

    },
    async getStakerStatus() {
      if(window.ethereum) {
        this.web3 = new Web3(web3.currentProvider)
        let address = await this.web3.eth.getAccounts()
        this.address = address[0]

        this.stakerContract = new this.web3.eth.Contract(Staker, this.stakerAddress)
        let status = await this.stakerContract.methods.getUserStackStatus().call({
          from: this.address
        })
        if (status) {
          this.showAddNavDialog = true;
        } else {
          this.$message.error('请到个人中心完成质押')
        }
        return status
      } else {
        this.$message.error('请到个人中心完成质押')
      }
    },
    closeDialog() {
        this.showAddNavDialog = false;
    },
  },
}
</script>

<style scoped>
.benefit-panel{
  height: 4rem;
  display: flex;
  flex-direction: row;
  align-items: center;
  background-color: white;
  border-radius: 4px;
  border: 1px solid #e6ebf5;
  color: #303133;
}
.benefit-content{
  margin: 0 2rem;
}
.benefit-description{
  flex-grow: 1;
}

.benefit-add{
  margin: 0 4rem;
}
</style>
