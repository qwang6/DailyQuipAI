# GitHub Pages Setup Guide

## ✅ 已完成的内容

所有App Store发布所需的网页已准备完毕，存放在 `docs/` 目录：

- ✅ `index.html` - 营销落地页
- ✅ `privacy.html` - 隐私政策（App Store必需）
- ✅ `support.html` - 支持页面（App Store必需）
- ✅ `terms.html` - 服务条款
- ✅ `CNAME` - 自定义域名配置文件
- ✅ `README.md` - 文档说明

---

## 🚀 启用 GitHub Pages（必须执行）

### 步骤 1：推送到 GitHub

```bash
cd /Users/qianwang/Downloads/my_projects/DailyQuipAI

# 添加所有新文件
git add docs/

# 提交
git commit -m "Add GitHub Pages with Privacy Policy, Support, and Terms pages for App Store submission"

# 推送到 GitHub
git push origin main
```

### 步骤 2：在 GitHub 启用 Pages

1. 访问你的仓库：https://github.com/qwang6/DailyQuipAI
2. 点击 **Settings** 标签
3. 左侧菜单找到 **Pages**
4. 在 "Source" 下：
   - Branch: 选择 `main`
   - Folder: 选择 `/docs`
5. 点击 **Save**

### 步骤 3：等待部署

- GitHub 会自动构建和部署（通常2-5分钟）
- 完成后会显示：✅ "Your site is live at https://qwang6.github.io/DailyQuipAI/"

---

## 📝 App Store Connect 使用的URL

一旦 GitHub Pages 启用，在 App Store Connect 中使用以下链接：

### 必填项：

**Privacy Policy URL（隐私政策）:**
```
https://qwang6.github.io/DailyQuipAI/privacy.html
```

**Support URL（支持链接）:**
```
https://qwang6.github.io/DailyQuipAI/support.html
```

### 可选项：

**Marketing URL（营销网站）:**
```
https://qwang6.github.io/DailyQuipAI/
```

**Terms of Service URL（服务条款）:**
```
https://qwang6.github.io/DailyQuipAI/terms.html
```

---

## 🌐 自定义域名设置（可选）

如果你拥有域名 `dailyquipai.app`：

### 步骤 1：配置 DNS

在你的域名注册商（Namecheap、GoDaddy等）添加：

**A Records:**
```
Host: @
Points to:
  185.199.108.153
  185.199.109.153
  185.199.110.153
  185.199.111.153
```

**CNAME Record:**
```
Host: www
Points to: qwang6.github.io
```

### 步骤 2：在 GitHub 设置自定义域名

1. GitHub Repository → Settings → Pages
2. "Custom domain" 输入: `dailyquipai.app`
3. 点击 Save
4. 等待 DNS 验证（可能需要几分钟到几小时）
5. ✅ 勾选 "Enforce HTTPS"

### 步骤 3：更新 App Store Connect URL

使用自定义域名后，更新为：
```
Privacy Policy: https://dailyquipai.app/privacy.html
Support URL: https://dailyquipai.app/support.html
```

---

## ✅ 验证清单

完成 GitHub Pages 设置后，检查：

- [ ] 访问 https://qwang6.github.io/DailyQuipAI/ 能看到落地页
- [ ] 访问 privacy.html 能看到隐私政策
- [ ] 访问 support.html 能看到支持页面
- [ ] 访问 terms.html 能看到服务条款
- [ ] 所有页面在手机浏览器显示正常
- [ ] 所有链接正常工作

---

## 📱 App Store Connect 填写示例

### App Information 页面：

| 字段 | 值 |
|------|-----|
| Privacy Policy URL | https://qwang6.github.io/DailyQuipAI/privacy.html |
| Support URL | https://qwang6.github.io/DailyQuipAI/support.html |
| Marketing URL (可选) | https://qwang6.github.io/DailyQuipAI/ |

### App Privacy 页面：

根据我们的隐私政策：
- ✅ **No, we do not collect data from this app**
- 因为我们不收集任何个人数据

---

## 🔧 故障排除

### GitHub Pages 未启用

如果 Settings → Pages 找不到：
1. 确保仓库是 public
2. 确保有 `docs/` 文件夹且已推送到 GitHub

### 404 错误

1. 检查 URL 是否正确（区分大小写）
2. 确认文件已推送到 main 分支
3. 等待几分钟让 GitHub 重新部署

### 自定义域名不工作

1. 检查 DNS 设置（使用 dig 或 nslookup）
2. DNS 传播可能需要 24-48 小时
3. 确保 CNAME 文件内容正确

---

## 📧 支持邮箱说明

网页中使用的邮箱地址：
```
support@dailyquipai.app
```

**重要提醒：**
- 你需要创建这个邮箱或使用转发
- 或者修改所有页面中的邮箱地址为你的真实邮箱

修改邮箱地址：
```bash
# 在 docs/ 目录下查找替换
find docs/ -name "*.html" -exec sed -i '' 's/support@dailyquipai.app/your-email@gmail.com/g' {} \;
```

---

## 🎉 完成！

按照以上步骤操作后：
1. GitHub Pages 将托管你的网页
2. App Store 审核需要的所有链接都已就绪
3. 用户可以访问隐私政策、支持页面和条款

**下一步：提交到 App Store Connect！** 🚀
