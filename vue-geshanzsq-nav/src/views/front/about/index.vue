<template>
  <div style="padding: 0px"
    v-loading="loading"
    element-loading-text="获取结果中..."
    element-loading-spinner="el-icon-loading"
    element-loading-background="rgba(0, 0, 0, 0.8)"
  >
    <front-home :menu-list="menuList">
      <div slot="mainContainer" style="padding: 20px;height: calc(100vh - 137px);">
        <div class="personal_contain">
          <div class="reward">
            <p style="margin-bottom: 12px;">作品累计点击量: {{ profit }}</p>
            <div>
              <el-tooltip class="item" effect="dark" :content="'(总点击量(' + profit + ') - 已领取收益(' + hasMintRedNum + ')) ÷ 5'" placement="top">
                <p>可换取收益: {{ acutalIncome }}Nav</p>
              </el-tooltip>
              <el-button :disabled="!stackStatus" @click="getReward">领取收益</el-button>
            </div>
            <div style="text-align:center">
              <p style="margin-bottom: 12px;">质押状态：{{stackStatus ? '已完成质押' : '未参与质押'}}</p>
              <div style="">
                <el-button :disabled="stackStatus" @click="showStakerDialog">参与质押</el-button>
                <el-button :disabled="!stackStatus" @click="cancelStaker">取消质押</el-button>
              </div>
            </div>
          </div>
          <!-- <p>我的创作</p> -->
          <el-row :gutter="24" >
            <h4 style="margin-left: 12px">
              <svg-icon icon-class="tag" style="margin-right: 7px;font-size: 18px"/>
              <span style="color: #555;font-size: 17px;font-weight:normal">我的创作</span>
            </h4>
            <el-col :sm="6" :sx="24" style="margin-bottom: 15px" :key="'sitecard' + index" v-for="(site, index) in siteList">
              <site-card :site="site" style="height: 90px"></site-card>
            </el-col>
          </el-row>
        </div>
      </div>
    </front-home>
    <el-dialog
        title="请完成创作者质押"
        :visible.sync="dialogVisible"
        width="70%"
        :before-close="handleClose">
        <div>
          <h4>为什么要进行创作者质押？</h4>
          <p>质押的目的是为了约束创作者，防止创作者上传违背社区价值，挑战社会公序良知的内容。如果创作者上传不符合社区规范的内容，我们会从创作者质押的代币中扣除一部分作为惩罚。</p>
        </div>
        <div>
          <h4>为什么要进行创作者质押？</h4>
          <p>目前，我们仅支持使用 MATIC币进行质押，质押数量不得低于0.01。点击下方【创作质押】按钮，根据提示即可完成创作者质押。</p>
        </div>
        <div>
          <h4>如何赎回创作者质押？</h4>
          <p>你可以前往个人中心，点击【解除质押】，我们会将你之前质押的MATIC返还到你的个人钱包；具体返还的数量=质押的数量-惩罚扣除的数量（在创作者作恶的情况下）。</p>
        </div>
        <el-dialog
          width="30%"
          title="创作者质押"
          :visible.sync="innerVisible"
          append-to-body>
          <div>
            <el-card class="box-card">
              <div>
                所需Matic代币数 0.01
              </div>
              <div>
                <p>注：</p>
                <p>1、质押所需的Matic数量跟随web3n/Matic交易滑点变动；</p>
                <p>2、确定质押后，质押完成时长取决于链上拥堵情况以及块更新速度，请耐心等待</p>
                <p>3、<a style="color: #5193d0" href="https://wiki.aavegotchi.com/cn/mumbai-testnet" target="_blank">如何获取MATIC(Mumbai)操作指引 >></a></p>
              </div>
            </el-card>
            <el-button style="width: 94%;margin-top: 15px;margin-left: 3%;" @click="staker" type="primary">确定质押</el-button>
          </div>
        </el-dialog>
        <span slot="footer" class="dialog-footer">
          <el-button @click="dialogVisible = false">取 消</el-button>
          <el-button type="primary" @click="goStaker">去完成质押</el-button>
        </span>
    </el-dialog>
  </div>
</template>

<script>
  import Web3 from 'web3';
  import FooterBottom from '@/components/FooterBottom'
  import FrontHome from '@/views/front/FrontHome';
  import Comment from './components/Comment'

  import { getNavAbout, getFrontMenu } from '@/api/front/frontNav'

  import Staker from '@/api/abi/Staker.json';
  import Nav from '@/api/abi/Nav.json';
  import NavReward from '@/api/abi/NavReward.json';

  import SiteCard from "@/components/SiteCard/SiteCard";

  import { mapState } from 'vuex'
  import ResizeMixin from '@/views/front/mixin/ResizeHandler'

  import { getUserFrontMenu, getUserClickCount } from '@/api/front/frontNav'

  export default {
    name: "about",
    components: {FooterBottom,FrontHome,Comment,SiteCard},
    data() {
      return {
        menuList: [],
        loading: false,
        // 图片基本地址
        baseUrl: process.env.VUE_APP_BASE_FILE,
        webConfig: {},
        stakerAddress: '0x3DAD3B10a77f4E0bA43c2FA79Cc48D5AB7B16F45',
        stackStatus: false,
        rewardAddress: '0x5Be0C36794b9f4Dcc5ec7553b50f84F223853Cd5',
        erc20Arress: '0x6Ac120B418223F1c059D61f751D568544Bf4104e',
        siteList: [],
        dialogVisible: false,
        innerVisible: false,
        hasMintRedNum: 0,
        profit: 0
      }
    },
    mixins: [ResizeMixin],
    computed: {
      ...mapState({
        device: state => state.app.device,
      }),
      isMobile() {
        return this.device === 'mobile';
      },
      acutalIncome() {
        let income = (this.profit - this.hasMintRedNum) / 5
        return income < 0 ? 0 : income
      }
    },
    created() {
      this.getFrontMenu();
      // this.getNavAbout();
    },
    methods: {
      //查询菜单
      getFrontMenu() {
        getFrontMenu().then(response => {
          this.menuList = response.menus;
        })
      },
      async getReward() {
        if (this.profit === this.hasMintRedNum) {
          this.$message.warning('你的可提现收益为0')
        } else {
          let distributContract = new this.web3.eth.Contract(NavReward.abi, this.rewardAddress, {from: this.address})
          distributContract.methods.mintNav(this.address).send({from: this.address})
            .on('transactionHash', (hash) => {
                  this.loading = true
              })
            .on('receipt', (receipt) => {
              if (receipt.status) {
                this.loading = false
                this.$message.success('提取成功，请稍后查看你的钱包余额')

                setTimeout(() => {
                  this.getReceived()
                }, 7000);
              } else {
                this.loading = false
                this.$message.success('提取失败')
              }
            })
        }
      },
      async staker() {
        if(window.ethereum) {
            this.stakerContract = new this.web3.eth.Contract(Staker, this.stakerAddress)
            this.innerVisible = false
            this.dialogVisible = false
            this.stakerContract.methods.stake().send({
              from: this.address,
              value: 1000000000
            })
              .on('transactionHash', (hash) => {
                this.loading = true
                // console.log(hash, '_transactionHash_')
              })
              .on('receipt', (receipt) => {
                if (receipt.status) {
                  this.loading = false
                  this.getStakerStatus()
                  this.$message.success('质押成功')
                } else {
                  this.loading = false
                  this.$message.success('质押失败')
                }
              })
        } else {
          this.$message.warning("请安装metamask钱包")
        }
      },
      checkAccounts() {
        if (this.web3 === null) return;
        this.web3.eth.getAccounts((err, accounts) => {
            if (err != null)
                return this.Log(this.MetamaskMsg.NETWORK_ERROR, "NETWORK_ERROR");
            if (accounts.length === 0) {
                this.account = "";
                this.Log(this.MetamaskMsg.EMPTY_METAMASK_ACCOUNT, "NO_LOGIN");
                return;
            }
            this.account = accounts[0]; // user Address
            this.$store.commit('SET_ADDRESS', this.account);
            this.isConnect = true;
        });
      },
      async getStakerStatus() {
        this.stakerContract = new this.web3.eth.Contract(Staker, this.stakerAddress)
        let status = await this.stakerContract.methods.getUserStackStatus().call({
          from: this.address
        })
        this.stackStatus = status
        return status
      },
      async initState() {
        if(window.ethereum) {
          this.web3 = new Web3(web3.currentProvider)
          let address = await this.web3.eth.getAccounts()
          // 记录钱包地址
          this.address = address[0]
          this.getStakerStatus()
          this.getUserNavList()
          this.getUserProfit()
          this.getReceived()
        }
      },
      async cancelStaker() {
        if(window.ethereum) {
          this.stakerContract.methods.withdraw().send({from: this.address})
          .on('transactionHash', (hash) => {
            this.loading = true
          })
          .on('receipt', (receipt) => {
            if (receipt.status) {
              this.loading = false
              this.$message.success('解除成功')
              this.stackStatus = false
              // this.getStakerStatus()
            } else {
              this.loading = false
              this.$message.success('解除失败')
            }
          })
        } else {
          this.$message.warning("请安装metamask钱包")
        }
      },
      getUserNavList() {
        let params = {
          userWalletAddress: this.address
        }
        getUserFrontMenu(params).then(response => {
          if (response.code == 200) {
            this.siteList = response.rows
          }
        }).catch(error => {
        })
      },
      getUserProfit() {
        let params = {
          userWalletAddress: this.address
        }
        getUserClickCount(params).then(response => {
          if (response.code == 200) {
            this.profit = response.data || 0
          }
        }).catch(error => {
        })
      },
      async getUserBalance() {
        if(window.ethereum) {
          this.web3 = new Web3(web3.currentProvider)
          let address = await this.web3.eth.getAccounts()
          this.address = address[0]
          this.ERCContract = new this.web3.eth.Contract(Nav.abi, this.erc20Arress)
          let result = await this.ERCContract.methods.balanceOf(this.address).call()
        }

      },
      async getReceived() {
        let distributContract =  new this.web3.eth.Contract(NavReward.abi, this.rewardAddress, {
          from: this.address
        })
        this.hasMintRedNum = await distributContract.methods.hasMintRedNum(this.address).call()
      },
      handleClose() {
        this.dialogVisible = false
      },
      showStakerDialog() {
        this.dialogVisible = true
      },
      goStaker() {
        this.innerVisible = true
      }
    },
    mounted() {
      this.getUserBalance()
    },
    beforeDestroy() {
      this.subscription
    },
    created() {
      this.initState()
    }
  }
</script>

<style scoped lang="scss">
.personal_contain {
  width: 100%;
  height: 100%;
  padding-top: 30px;
  .reward {
    width: 100%;
    height: 100px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    border: 1px solid #ccc;
    background-color: #ffffff;
    padding: 5px 20px;
    box-sizing: border-box;
  }
}
</style>
