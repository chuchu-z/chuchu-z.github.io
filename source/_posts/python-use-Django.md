---
title: 'Python 使用 Django 框架'
date: 2024-1-15 09:41:42
categories: 
- Python
---



> 有个项目需要用对接 ChatGpt 的API, 本来想拿老本行 PHP 写的, 但是 PHP 没有 Python 对接起来方便, 且我觉得语言只是工具, 每个语言都有它的优点和优势, 同时还能多多接触新东西, 利于学习。 



<!--more-->



## 一. 初始化

```shell
# 安装
pip install Django

# 创建项目名
django-admin startproject your_project_name

cd your_project_name

# 创建应用名
python manage.py startapp your_app_name
```



## 二. 修改settings.py配置



### 2.1 引入env

```python
import os
from pathlib import Path
from dotenv import load_dotenv

# 加载环境变量
load_dotenv()
```



### 2.2 配置数据库

```python
# Database
# https://docs.djangoproject.com/en/5.0/ref/settings/#databases
# mysql 版本使用5.7, 但Django要求8.0以上
# 全局搜索 check_database_version_supported ,并注释, 就不会检查mysql版本
# 位置大约在django/db/backends/base/base.py文件255行

DATABASES = {
    # 'default': {
    #     'ENGINE': 'django.db.backends.sqlite3',
    #     'NAME': BASE_DIR / 'db.sqlite3',
    # }
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': os.getenv("DB_NAME", ''),
        'USER': os.getenv("DB_USER", ''),
        'PASSWORD': os.getenv("DB_PASSWORD", ''),
        'HOST': '127.0.0.1',  # 或者是数据库服务器的IP地址
        'PORT': '3306',  # MySQL默认端口
        'OPTIONS': {
            'charset': 'utf8mb4',
            'collation': 'utf8mb4_general_ci',
            # 'init_command': "SET sql_mode='STRICT_TRANS_TABLES'",
        },
    }
}
```



### 2.3 修改其他配置

```python
# 我的项目全是外部接口, 所以用不上表单和csrf, 注释csrf
MIDDLEWARE = [
    ...
    # 'django.middleware.csrf.CsrfViewMiddleware',
    ...
]
```



### 2.4 语言与时区

```python
LANGUAGE_CODE = 'zh-hans'

TIME_ZONE = 'Asia/Shanghai'

DATE_FORMAT = 'Y-m-d'
DATETIME_FORMAT = 'Y-m-d H:i'

USE_I18N = True

USE_TZ = False
```



### 2.5 默认自增主键

```python
DEFAULT_AUTO_FIELD = 'django.db.models.AutoField'
```



## 三. 使用Django

```shell
# 数据迁移
python manage.py makemigrations
python manage.py migrate

# 启动服务器, 可指定端口或指定ip+端口
python manage.py runserver
python manage.py runserver 8080
python manage.py runserver 0.0.0.0:8000

# 创建管理员
python manage.py createsuperuser

# 搞定后登录管理
http://127.0.0.1:8000/admin/
```



## 四. model示例

> 说实话, django的model和数据迁移做的真不好, 和laravel的migrate对比, 很多东西都不符合常理, 比如默认datetime(6), 还自带小数点

```python
from django.db import models


# 自定义 datetime 字段, 因为 django 默认datetime(6)
class MySQLDateTimeField(models.DateTimeField):
    def db_type(self, connection):
        return 'datetime'


class UploadedFile(models.Model):
    id = models.AutoField(primary_key=True)
    file_id = models.CharField(max_length=50, null=False, blank=True, db_default="", db_comment="文件ID")
    file_name = models.CharField(max_length=255, null=False, blank=True, db_default="", db_comment="文件名")
    file_size = models.IntegerField(null=False, db_default=0, blank=True, db_comment="文件大小")
    file_status = models.CharField(max_length=50, null=False, blank=True, db_default="uploaded", db_comment="文件状态")
    file_purpose = models.CharField(max_length=50, null=False, blank=True, db_default="fine-tune", db_comment="文件用途")
    created_at = MySQLDateTimeField(auto_now_add=True, db_comment="创建时间")
    objects = models.Manager()

    class Meta:
        db_table = "chatgpt_upload_files"
        indexes = [
            models.Index(fields=["file_id", "file_status", "created_at"], name="idx_file_id_status_create"),  # 联合索引
        ]
        verbose_name = "上传文件表"
        verbose_name_plural = "上传文件表"

    def __str__(self):
        return self.file_id

```

