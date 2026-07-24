# OpenList Dockerfile for Choreo

# Version

v4.2.4-lite

# Releases

Upstream OpenList `v4.2.4` (lite image for PaaS / limited ephemeral storage).

- Upstream: https://github.com/OpenListTeam/OpenList/releases/tag/v4.2.4
- Docs: https://doc.oplist.org/

### &nbsp;&nbsp;&nbsp;🚀 Features

- **azure_blob**: Preserve content type and md5 &nbsp;-&nbsp; by @NewFuture in https://github.com/OpenListTeam/OpenList/issues/2734 [<samp>(a283f)</samp>](https://github.com/OpenListTeam/OpenList/commit/a283f2b5)
- **drivers**: Add Bunny Storage driver &nbsp;-&nbsp; by @demogest and **Codex** in https://github.com/OpenListTeam/OpenList/issues/2472 [<samp>(791a2)</samp>](https://github.com/OpenListTeam/OpenList/commit/791a27e2)
- **drivers/139**: Merge multiple share roots &nbsp;-&nbsp; by @syscc in https://github.com/OpenListTeam/OpenList/issues/2783 [<samp>(0a9e7)</samp>](https://github.com/OpenListTeam/OpenList/commit/0a9e71ae)

### &nbsp;&nbsp;&nbsp;🐞 Bug Fixes

- **115,115share**:
  - Update github.com/SheltonZhu/115driver to v1.3.4 &nbsp;-&nbsp; by @SheltonZhu in https://github.com/OpenListTeam/OpenList/issues/2794 [<samp>(24332)</samp>](https://github.com/OpenListTeam/OpenList/commit/24332e37)
- **115_open**:
  - Clean parent path before lookup &nbsp;-&nbsp; by @syscc in https://github.com/OpenListTeam/OpenList/issues/2820 [<samp>(a21bc)</samp>](https://github.com/OpenListTeam/OpenList/commit/a21bc8bd)
- **buffer**:
  - Wait for active I/O before closing &nbsp;-&nbsp; by @jyxjjj and **Codex** in https://github.com/OpenListTeam/OpenList/issues/2825 [<samp>(e8383)</samp>](https://github.com/OpenListTeam/OpenList/commit/e83835dd)
- **deps**:
  - Update github.com/t3rm1n4l/go-mega digest to 4de2f12 &nbsp;-&nbsp; in https://github.com/OpenListTeam/OpenList/issues/2710 [<samp>(94eac)</samp>](https://github.com/OpenListTeam/OpenList/commit/94eac2e9)
  - Update module github.com/dlclark/regexp2 to v1.12.0 &nbsp;-&nbsp; in https://github.com/OpenListTeam/OpenList/issues/2713 [<samp>(757f9)</samp>](https://github.com/OpenListTeam/OpenList/commit/757f9d38)
  - Update module gorm.io/driver/sqlite to v1.6.0 &nbsp;-&nbsp; in https://github.com/OpenListTeam/OpenList/issues/2757 [<samp>(a81f5)</samp>](https://github.com/OpenListTeam/OpenList/commit/a81f5448)
  - Update module gorm.io/driver/postgres to v1.6.0 &nbsp;-&nbsp; in https://github.com/OpenListTeam/OpenList/issues/2756 [<samp>(daaba)</samp>](https://github.com/OpenListTeam/OpenList/commit/daaba0d7)
  - Update module google.golang.org/grpc to v1.82.0 &nbsp;-&nbsp; in https://github.com/OpenListTeam/OpenList/issues/2754 [<samp>(8930e)</samp>](https://github.com/OpenListTeam/OpenList/commit/8930e194)
  - Update module github.com/maruel/natural to v1.3.0 &nbsp;-&nbsp; in https://github.com/OpenListTeam/OpenList/issues/2739 [<samp>(e6703)</samp>](https://github.com/OpenListTeam/OpenList/commit/e670322e)
  - Update module github.com/quic-go/quic-go to v0.60.0 &nbsp;-&nbsp; in https://github.com/OpenListTeam/OpenList/issues/2743 [<samp>(f3e74)</samp>](https://github.com/OpenListTeam/OpenList/commit/f3e74fbd)
  - Update module github.com/shirou/gopsutil/v4 to v4.26.6 &nbsp;-&nbsp; in https://github.com/OpenListTeam/OpenList/issues/2745 [<samp>(5aeaf)</samp>](https://github.com/OpenListTeam/OpenList/commit/5aeaf7a8)
  - Update module github.com/protonmail/gopenpgp/v2 to v2.10.0 &nbsp;-&nbsp; in https://github.com/OpenListTeam/OpenList/issues/2742 [<samp>(651b5)</samp>](https://github.com/OpenListTeam/OpenList/commit/651b5cea)
  - Update module github.com/go-resty/resty/v2 to v2.17.2 &nbsp;-&nbsp; in https://github.com/OpenListTeam/OpenList/issues/2718 [<samp>(b1d29)</samp>](https://github.com/OpenListTeam/OpenList/commit/b1d298d1)
  - Update module github.com/deckarep/golang-set/v2 to v2.9.0 &nbsp;-&nbsp; in https://github.com/OpenListTeam/OpenList/issues/2712 [<samp>(0527d)</samp>](https://github.com/OpenListTeam/OpenList/commit/0527dc41)
  - Update module github.com/nwaples/rardecode/v2 to v2.2.5 &nbsp;-&nbsp; in https://github.com/OpenListTeam/OpenList/issues/2699 [<samp>(59612)</samp>](https://github.com/OpenListTeam/OpenList/commit/5961289b)
  - Update module github.com/bodgit/sevenzip to v1.6.5 &nbsp;-&nbsp; in https://github.com/OpenListTeam/OpenList/issues/2789 [<samp>(e4696)</samp>](https://github.com/OpenListTeam/OpenList/commit/e4696931)
  - Update module gorm.io/gorm to v1.31.2 &nbsp;-&nbsp; in https://github.com/OpenListTeam/OpenList/issues/2758 [<samp>(6b702)</samp>](https://github.com/OpenListTeam/OpenList/commit/6b702afc)
  - Update module github.com/rclone/rclone to v1.74.4 &nbsp;-&nbsp; in https://github.com/OpenListTeam/OpenList/issues/2744 [<samp>(36168)</samp>](https://github.com/OpenListTeam/OpenList/commit/36168c86)
  - Update github.com/t3rm1n4l/go-mega digest to c6acd6a &nbsp;-&nbsp; in https://github.com/OpenListTeam/OpenList/issues/2829 [<samp>(2deb1)</samp>](https://github.com/OpenListTeam/OpenList/commit/2deb16b2)
- **drivers/115_open**:
  - Populate file size when resolving paths &nbsp;-&nbsp; by @sevxn007 in https://github.com/OpenListTeam/OpenList/issues/2797 [<samp>(7aea3)</samp>](https://github.com/OpenListTeam/OpenList/commit/7aea393a)
  - Recover transient path metadata &nbsp;-&nbsp; by @Suyunmeng and **Claude** in https://github.com/OpenListTeam/OpenList/issues/2816 [<samp>(e1ded)</samp>](https://github.com/OpenListTeam/OpenList/commit/e1ded83d)
- **drivers/s3**:
  - Custom user agent and method fixes &nbsp;-&nbsp; by @xrgzs and **GitHub Copilot** in https://github.com/OpenListTeam/OpenList/issues/2780 [<samp>(eb486)</samp>](https://github.com/OpenListTeam/OpenList/commit/eb486712)
  - Support multipart object copy &nbsp;-&nbsp; by @jyxjjj, **Codex** and **Pikachu Ren** in https://github.com/OpenListTeam/OpenList/issues/2826 [<samp>(fe56c)</samp>](https://github.com/OpenListTeam/OpenList/commit/fe56ca48)
- **handles**:
  - Add src_name validation in FsBatchRename &nbsp;-&nbsp; by @jyxjjj and @xrgzs [<samp>(651da)</samp>](https://github.com/OpenListTeam/OpenList/commit/651da18d)
- **proxy**:
  - Preserve proxied download filenames &nbsp;-&nbsp; by @jyxjjj and **Codex** in https://github.com/OpenListTeam/OpenList/issues/2824 [<samp>(28cea)</samp>](https://github.com/OpenListTeam/OpenList/commit/28cea1fb)
- **search**:
  - Serialize index updates by parent &nbsp;-&nbsp; by @jyxjjj, **Codex** and **Pikachu Ren** in https://github.com/OpenListTeam/OpenList/issues/2827 [<samp>(84954)</samp>](https://github.com/OpenListTeam/OpenList/commit/8495470e)
  - Apply access filtering before paginating results &nbsp;-&nbsp; by @jyxjjj [<samp>(84ecd)</samp>](https://github.com/OpenListTeam/OpenList/commit/84ecda35)
- **sharing**:
  - Enforce base path boundaries &nbsp;-&nbsp; by @jyxjjj [<samp>(59bd3)</samp>](https://github.com/OpenListTeam/OpenList/commit/59bd3431)

##### &nbsp;&nbsp;&nbsp;&nbsp;[View changes on GitHub](https://github.com/OpenListTeam/OpenList/compare/v4.2.3...v4.2.4)

部署说明见 [README.choreo.md](./README.choreo.md)。
