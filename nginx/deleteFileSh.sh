# 凌晨2点执行，查找目录下面7天内没有被访问的文件并删除，释放空间
# 此脚本存在一定问题，不是全部read操作都可以改变文件状态，不建议使用
0 2 * * * find /data/images -atime -7 | xargs rm -rf

# 最佳流程是：
# 1）只删除经过缩放、优化的图片
# 2）删除一段时间（如：7天）以前创建的文件名形如 /([a-zA-Z0-9]+)_([0-9]+x[0-9]+)?(q[0-9]{1,2})?.([a-zA-Z0-9]+)/ 的优化后的图片文件
# 3）linux技能有限，正在调研如何实现……