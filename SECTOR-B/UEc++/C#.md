## VS测试环境搭建

### 新建项目



## 循环

### for

```c#
//for (初始表达式；条件表达式；增量表达式)
//{循环体}
for (int i = 1; i <= 10; i++)
{
    Console.WriteLine(i);
}//输出：1到10
```

### while

```c#
int i = 1;
while (i <= 9) //直到i满足括号内条件结束循环
{
    Console.WriteLine(i);
    i++;
}//输出：1到9
```

### do - while

```c#
do
{
    //不管条件先执行一次，后进入条件判断
}
while(i < 9);
```

### break 和 continue

`break` 立刻结束循环，不继续后面的循环。

`continue` 立刻结束本次循环，会继续完成剩下的循环。

```c#
for(int i = 0; i <= 10; i++)
{
    if(i % 2 == 0){
        continue;
    }
    Console.WriteLine(i);
}
```



## 判断

### if - else

特点：处理多条件（>2个）的**区间**判断。

```c#
if (...)
{...}
else if (...)
{...}
else
{...}
```



### switch - case

特点：处理多条件（>2个）的**定值**判断。

```c#
int w = 9;
switch(w - 5){ //值为4（括号里可以做运算）
    case 1: //固定的值：定值
        Console.WriteLine("周一");
        break;
    case 2:
        Console.WriteLine("周二");
        break;
    case 6:
        Console.WriteLine("周六");
        break;
    default:
        Console.WriteLine("其他");
        break;
}
Console.ReadKey(); //Pause
```

