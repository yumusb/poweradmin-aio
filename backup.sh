#!/bin/bash

# 检查是否存在 .env 文件
if [ ! -f .env ]; then
    echo ".env 文件不存在"
    exit 1
fi

# 读取数据库根密码
DB_ROOT_PASS=$(grep "DB_ROOT_PASS=" .env | cut -d '=' -f 2)

# 获取脚本所在目录
SCRIPT_DIR=$(dirname "$(realpath "$0")")
cd "$SCRIPT_DIR" || exit

# 设置备份目录和文件名
backup_dir="$SCRIPT_DIR/backups"
backup_filename="pdns_backup_$(date +%Y-%m-%d_%H-%M-%S).sql"
backup_filepath="${backup_dir}/${backup_filename}"

# 创建备份目录
mkdir -p "$backup_dir" || { echo "无法创建备份目录"; exit 1; }

# 执行数据库备份
docker compose exec db /usr/bin/mysqldump -u root --password="$DB_ROOT_PASS" pdns > "$backup_filepath" || { echo "数据库备份失败"; exit 1; }

# 输出备份完成信息
echo "备份完成: $backup_filepath"

# 删除旧的备份文件，只保留最新的三份备份
ls -1tr "${backup_dir}" | head -n -3 | xargs -r rm -f --

# 输出删除旧备份文件的信息
echo "旧的备份文件已删除，只保留最新的三份备份。"

# 添加备份文件到 Git
git add backups/ || { echo "添加备份文件到 Git 失败"; exit 1; }

# 提交备份文件到 Git
git commit -m "Added backup on $(date +%Y-%m-%d_%H-%M-%S)" || { echo "提交备份文件到 Git 失败"; exit 1; }

# 推送备份文件到 Git
git push || { echo "推送备份文件到 Git 失败"; exit 1; }

# 输出 Git 推送完成信息
echo "Git push 完成。"
