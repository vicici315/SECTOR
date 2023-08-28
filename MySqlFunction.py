import os
import pymysql
from configparser import ConfigParser
import wx

conf = ConfigParser()
setPath = os.getcwd()+'\\PrinterSetting.ini'
NET=False
if os.path.exists(setPath):
    conf.read_file(open(setPath, encoding='utf-8'))


# 创建连接池
# try:
#     # 创建一个MySQL数据库链接
#     connection = pymysql.connect(
#         host=conf.get('set_DS', 'HOST'),
#         port=3326,
#         user="root",
#         password="root4321",
#         database="mysql"
#     )
#     # auth_plugin = 'mysql_native_password'  # 注意：mysql.connector库只支持该密码方式，而Mysql8默认是caching_sha2_password
#     NET = True
# except pymysql.Error as e:
#     NET = False
#     dlg = wx.MessageDialog( f"数据库链接异常: {str(e)}", "[ ]", wx.ICON_EXCLAMATION)
#     dlg.ShowModal()
#     dlg.Destroy()
#==================================================================

#检查服务器并创建sql数据库链接
def check_sql():
    global NET  #修改全局变量时需要global声明，只读不需要
    conf.read_file(open(setPath, encoding='utf-8')) #！注意：这里需要重新读取ini才可以即时get到更新
    if NET:
        try:
            connection = pymysql.connect(
                host=conf.get('set_DS', 'HOST'),
                port=3326,
                user="root",
                password="root4321",
                database="mysql"
            )
            NET = True
            return connection
        except pymysql.Error as e:
            NET = False
            dlg = wx.MessageDialog(None,f"数据库链接异常: {e}", " ", wx.ICON_EXCLAMATION)
            dlg.ShowModal()
            dlg.Destroy()
            return None

#检查键是否存在
def SQL_value_exist(Table,val):
    connect = check_sql()
    if connect is not None:
        cursor = connect.cursor()
        check_query = f"SHOW TABLES LIKE %s"
        cursor.execute(check_query, (Table,))
        result = cursor.fetchone()
        if result:
            exists_query = f"SELECT EXISTS (SELECT 1 FROM `{Table}` WHERE `key_string` = %s)"
            try:
                # 执行查询操作
                cursor.execute(exists_query, (val,))
                # 获取查询结果
                value_exists = cursor.fetchone()[0]
                if value_exists:    #存在返回1
                    return True
            except:
                return False
        else:
            return False

# 获取表成员数量
def SQL_get_num(Table):
    member_count = 0
    connect = check_sql()
    if connect is not None:
        # 创建游标对象
        cursor = connect.cursor()
        check_query = f"SHOW TABLES LIKE %s"  # 注意：为避免table_name有特殊字符，这里要用反引号包裹``改用占位符
        cursor.execute(check_query,(Table,))
        result = cursor.fetchone()
        if result:
        # 检查表是否已存在
            count_query = f"SELECT COUNT(*) FROM `{Table}`"  # 注意：这里需将Table用``包裹，避免传入的表名有特殊字符
            cursor.execute(count_query)
            member_count = cursor.fetchone()[0]
            cursor.close()
    connect.close()

    return member_count

# 删除表中value_string列的对应键值
def SQL_del_key(Table,val):
    connect = check_sql()
    if connect is not None:
        # 创建游标对象
        cursor = connect.cursor()
        # 查询是否存在该表
        delete_query = f"DELETE FROM `{Table}` WHERE `value_string` = %s"
        try:
            # 执行删除操作
            cursor.execute(delete_query, (val,))
            connect.commit()
        except:
            pass
        # 关闭游标和数据库连接
        connect.close()
        cursor.close()

# 删除表
def SQL_del_table(Table):
    connect = check_sql()
    if connect is not None:
        # 创建游标对象
        cursor = connect.cursor()
        # 查询是否存在该表
        check_query = f"SHOW TABLES LIKE %s"  # 这里无法使用反引号，改用占位符
        cursor.execute(check_query, (Table,))
        result = cursor.fetchone()
        if result:
            drop_table_query = f"DROP TABLE `{Table}`"
            cursor.execute(drop_table_query)
            # delete_query = f"DELETE FROM `{Table}`"   #删除所有成员
            # # 执行删除操作
            # cursor.execute(delete_query)
            # # 提交更改到数据库
            connect.commit()
        connect.close()
        # 关闭游标和数据库连接
        cursor.close()

# 写入序号加字符串值(传入多数值列表)
def SQL_set_values(Table, val_list):  # 传入：(表名，[值])
    connect = check_sql()
    if connect is not None:
        cursor = connect.cursor()
        check_query = f"SHOW TABLES LIKE %s"    #这里无法使用反引号，改用占位符
        cursor.execute(check_query,(Table,))
        result = cursor.fetchone()
        if not result:
            create_table_sql = f"""
                CREATE TABLE `{Table}` (
                    value_string TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
                );
                """
            cursor.execute(create_table_sql)
        connect.begin() #开始事务
        insert_query = f"INSERT INTO `{Table}` (value_string) VALUES (%s)"
        # 执行插入
        cursor.executemany(insert_query, val_list)
        connect.commit()  # 记得提交写入
        connect.close()
        cursor.close()
        return True
    else:
        return False

# 写入序号加字符串值(重复不写入)
def SQL_set_value(Table, value):  # 传入：(表名，值)
    connect = check_sql()
    if connect is not None:
        cursor = connect.cursor()
        check_query = f"SHOW TABLES LIKE %s"
        cursor.execute(check_query,(Table,))
        result = cursor.fetchone()
        if not result:
            create_table_sql = f"""
                CREATE TABLE `{Table}` (
                    value_string TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
                );
                """
            cursor.execute(create_table_sql)
        check_query = f"SELECT * FROM `{Table}` WHERE `value_string` = %s"
        cursor.execute(check_query, (value,))  # 这里的传入占位符变量只有一个也需要加逗号
        existing_row = cursor.fetchone()
        if existing_row:
            update_query = f"UPDATE `{Table}` SET value_string = %s"  # WHERE是一个过滤条件，指定了在哪些行中进行更新操作
            # 传入data_to_update 要更新是数据分别替换两个占位符%s
            cursor.execute(update_query, [value])
        else:
            insert_query = f"INSERT INTO `{Table}` (value_string) VALUES (%s)"
            # 执行插入
            cursor.execute(insert_query, [value])
            connect.commit()  # 记得提交写入
        connect.close()
        cursor.close()

# 写入字符串键与值
def SQL_set_key_value(Table, key, value):  # 传入：(表，键，值)
    connect = check_sql()
    if connect is not None:
        cursor = connect.cursor()
        check_query = f"SHOW TABLES LIKE %s"  # 这里无法使用反引号，改用占位符
        cursor.execute(check_query, (Table,))
        result = cursor.fetchone()
        if not result:
            create_table_sql = f"""
                            CREATE TABLE `{Table}` (
                                key_string VARCHAR(128) PRIMARY KEY,
                                value_string TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
                            );
                            """
            cursor.execute(create_table_sql)
        check_query = f"SELECT * FROM `{Table}` WHERE `key_string` = %s"
        cursor.execute(check_query, (key,))  # 这里的传入占位符变量只有一个也需要加逗号
        existing_row = cursor.fetchone()

        if existing_row:
            # 更新数据，查找`key_string`是否等于key_to_update，设置value_string列的值
            update_query = f"UPDATE `{Table}` SET value_string = %s WHERE `key_string` = %s"  # WHERE是一个过滤条件，指定了在哪些行中进行更新操作
            # 传入data_to_update 要更新是数据分别替换两个占位符%s
            cursor.execute(update_query, (value, key))
        else:
            # 插入数据的SQL语句
            insert_query = f"INSERT INTO `{Table}` (key_string, value_string) VALUES (%s, %s)"
            # 执行批量插入
            data_to_insert = (key, value)
            cursor.execute(insert_query, data_to_insert)
        connect.commit()  # 记得提交写入

            # 执行创建表操作
        connect.close()
        cursor.close()
    # 检查表是否已存在
    # try:
    #     # 创建表格（创建表格需要确定好数据类型，否则后面无法修改需要删除重建）
    #     # value_string列使用了TEXT数据类型，并指定了字符集为utf8mb4以及校对规则为utf8mb4_unicode_ci。这是一种常见的字符集和校对规则设置，可以适应大多数的字符串需求
    #     create_table_sql = f"""
    #             CREATE TABLE `{Table}` (
    #                 key_string VARCHAR(128) PRIMARY KEY,
    #                 value_string TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
    #             );
    #             """
    #     # 执行创建表操作
    #     cursor.execute(create_table_sql)
    #     # 检查列：key_string是否存在要更新的键
    #     check_query = f"SELECT * FROM `{Table}` WHERE `key_string` = %s"
    #     cursor.execute(check_query, (key,))  # 这里的传入占位符变量只有一个也需要加逗号
    #     existing_row = cursor.fetchone()
    #
    #     if existing_row:
    #         # 更新数据，查找`key_string`是否等于key_to_update，设置value_string列的值
    #         update_query = f"UPDATE `{Table}` SET value_string = %s WHERE `key_string` = %s"  # WHERE是一个过滤条件，指定了在哪些行中进行更新操作
    #         # 传入data_to_update 要更新是数据分别替换两个占位符%s
    #         cursor.execute(update_query, (value, key))
    #     else:
    #         # 插入数据的SQL语句
    #         insert_query = f"INSERT INTO `{Table}` (key_string, value_string) VALUES (%s, %s)"
    #         # 执行批量插入
    #         data_to_insert = (key, value)
    #         cursor.execute(insert_query, data_to_insert)
    #     connection.commit()  # 记得提交写入

#获取表中所有的值
def SQL_get_allvalue(Table):
    all_row=[]
    connect = check_sql()
    if connect is not None:
        Table = ConvetToText(Table)
        # 创建游标对象
        cursor = connect.cursor()
        # 检查表是否已存在
        check_table_query = f"SHOW TABLES LIKE %s"
        cursor.execute(check_table_query, (Table,))
        table_exists = cursor.fetchone()
        if table_exists:
            # 检查列：key_string是否存在要更新的键
            check_query = f"SELECT * FROM `{Table}`"
            cursor.execute(check_query)  # 这里的传入占位符变量只有一个也需要加逗号
            row = cursor.fetchall()   #注意：fetchall() 获取所有数据
            if row:
                for r in row:
                    all_row.append(r[0])
            else:
                print(f"<Value '{row}' 不存在>")
        else:
            print(f"<Table '{Table}' 不存在>")
        connect.close()
        cursor.close()
    return all_row

#获取表中键的值
def SQL_get_key_value(Table, key):
        # 创建游标对象
    connect = check_sql()
    if connect is not None:
        cursor = connect.cursor()
        check_table_query = f"SHOW TABLES LIKE %s"
        cursor.execute(check_table_query,(Table,))
        table_exists = cursor.fetchone()
        if table_exists:
            # 检查列：key_string是否存在要更新的键
            check_query = f"SELECT * FROM `{Table}` WHERE `key_string` = %s"
            cursor.execute(check_query, (key,))  # 这里的传入占位符变量只有一个也需要加逗号
            existing_row = cursor.fetchone()
            if existing_row:
                return existing_row[1]
            else:
                return ''
        connect.close()
        cursor.close()
    else:
        return ''

def ConvetToText(path):
    if path != '':
        if '\\' in path:
            nf = path.replace('\\', '!')
        else:
            nf = path
        if ':' in nf:
            nf = nf.replace(':', '=')
        return nf

def check_table_exists(table_name):
    connect = check_sql()
    if connect is not None:
        cursor = connect.cursor()
        check_query = f"SHOW TABLES LIKE %s"  #注意：为避免table_name有特殊字符，这里要用反引号包裹``
        cursor.execute(check_query,(table_name,))
        result = cursor.fetchone()
        cursor.close()
        connect.close()
        return result is not None