<template>
  <el-dialog
    :title="$t('nav.add')"
    :visible.sync="showDialog"
    :before-close="closeDialog"
    :close-on-click-modal="false"
    class="dialog">
      <div class="dialog-content">
        <el-form :model="ruleForm" :rules="rules" ref="ruleForm"  class="ruleForm">
          <el-form-item label="请选择你要添加的导航分类" prop="menuId">
            <el-select v-model="ruleForm.menuId">
              <el-option v-for="nav in menus" 
              :key="nav.menuId" 
              :label="nav.menuName" 
              :value="nav.menuId"></el-option>
             </el-select>
          </el-form-item>
          <el-form-item label="请填写导航名称" prop="menuName">
            <el-input
                    type="text"
                    placeholder="请输入导航名称"
                    v-model="ruleForm.menuName"
                    maxlength="24"
                    show-word-limit
                  >
                  </el-input>
          </el-form-item>
          <el-form-item label="请填写导航介绍" prop="siteDescription">
            <el-input
                  type="textarea"
                  placeholder="请输入内容"
                  v-model="ruleForm.siteDescription"
                  maxlength="100"
                  show-word-limit
                ></el-input>
          </el-form-item>
          <el-form-item label="请填写导航链接" prop="siteUrl">
             <el-input
                type="text"
                placeholder="请输入导航链接"
                v-model="ruleForm.siteUrl"
              >
              </el-input>
          </el-form-item>
           <!-- <el-form-item label="请上传导航图片" prop="navPic">
              <el-upload
                action="#"
                list-type="picture-card"
                :on-preview="handlePictureCardPreview"
                :on-remove="handleRemove"
                :on-change="handleChange"
                :auto-upload="false">
                <i class="el-icon-plus"></i>
              </el-upload>
              <el-dialog :visible.sync="dialogVisible">
                <img width="100%" :src="dialogImageUrl" alt="">
              </el-dialog>
           </el-form-item> -->
        </el-form>
        <span slot="footer" class="dialog-footer">
          <el-button @click="submit" type="primary">确认发布</el-button>
          <el-button @click="closeDialog">取    消</el-button>
        </span>
      </div>
  </el-dialog>
</template>

<script>
import { mapGetters } from "vuex";
import { addSiteInfo } from '@/api/front/frontNav';
import { create } from 'ipfs-http-client'

export default {
  name: 'addNavDialog',
  components: { },
  props: {
    showDialog:{
      type: Boolean,
      default: false,
    },
  },
  data() {
    const ipfs = create('https://ipfs.infura.io:5001')
    return {
        dialogImageUrl: '',
        dialogVisible: false,
        ruleForm: {
          menuId: '',
          menuName: '',
          siteDescription: '',
          siteUrl: '',
        },
        rules: {
          menuName: [
            { required: true, message: '请输入导航名称', trigger: 'blur' },
            { min: 3, max: 10, message: '长度在 3 到 5 个字符', trigger: 'blur' }
          ],
          menuId: [
            { required: true, message: '请选择活动区域', trigger: 'change' }
          ],
          siteUrl: [
            { required: true, message: '请输入导航链接', trigger: 'blur' },
          ],
          desc: [
            { required: true, message: '请填写活动形式', trigger: 'blur' }
          ]
        },
        ipfs: ipfs,
    }
  },
  created() {
  },
  mounted() {
  },
  computed: {
    ...mapGetters(['menus'])
  },
  methods: { 
    closeDialog() {
      this.$refs['ruleForm'].resetFields();
      this.$emit('close');
    },
    handleRemove(file, fileList) {
        console.log(file, fileList);
    },
    handlePictureCardPreview(file) {
      this.dialogImageUrl = file.url;
      this.dialogVisible = true;
    },
    handleChange(file, fileList) {
      console.log(file, fileList);
    },
    submit(){
       this.$refs['ruleForm'].validate(async (valid) => {
          if (valid) {
            const walletAddress = this.$store.getters.address;
            let site = {
              ...this.ruleForm,
              walletAddress,
            };
            const buf = new Buffer.from(site.toString());
            const added = await this.ipfs.add(buf);
            const ipfsUrl = `https://ipfs.infura.io/ipfs/${added.path}`
            site = {
              ...site,
              ipfsUrl,
            }
            addSiteInfo(site).then(res => {
                console.log(res);
                this.closeDialog();
            })
          } else {
            console.log('error submit!!');
            return false;
          }
        });
    },
    uploadToIPFS(data) {
      return new Promise(function(resolve, reject) {
        const result = this.ipfs.add(data)
        resolve(result);
      }, (err) => {
        reject(err);
      })
    },
  }
}
</script>

<style>
.dialog-content{

}

.dialog-item{
  margin: .5rem;
}

.dialog-item-title{
  margin: .5rem;
}
.el-form-item__label{
  display: block;
  text-align: left;
  float: none;
}
.dialog-item-content{

}
</style>
