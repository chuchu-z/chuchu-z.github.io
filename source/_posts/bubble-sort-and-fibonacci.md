---
title: 浅记冒泡排序及斐波那契数列优化点
date: 2023-2-16 19:04:13
tags: 
- PHP
- 算法
categories: 
- PHP
- 算法

---



# 冒泡排序

> 一般的冒泡排序只能满足最基本的要求, 如果不加以优化, 还会多做无用功, 出现重复循环的无效排序。

<!--more-->

#### 常规冒泡排序** 

```php
<?php

$arr = [2,-3,-10,4,-5,6,7,8,12,9,1,-11,100,-200,300,400,500];
$len = count($arr);

for($i = 0; $i < $len - 1; $i++)
{
    for($j = 0; $j < $len - $i - 1; $j++)
    {
        if ($arr[$j] > $arr[$j + 1])
        {
            $item = $arr[$j];
            $arr[$j] = $arr[$j + 1];
            $arr[$j+1] = $item;
        }
    }
}

var_dump($arr);
```



#### 优化点1

> 如  **[1,2,3,5,4 ]**  , 只需要排序一遍的, 我们可以增加标识位表示当前是有序或无序,已经是有序的情况可直接退出循环。

```php
<?php

$arr = [2,-3,-10,4,-5,6,7,8,12,9,1,-11,100,-200,300,400,500];

$len = count($arr);
$index = $len - 1;//排序下限
$maxIndex = 0; //排序上限

for($i = 0; $i < $len - 1; $i++)
{
    //定义标识位标记已经有序或无序
    $flag = true;
    
    for($j = 0; $j < $len - $i - 1; $j++)
    {
        if ($arr[$j] > $arr[$j + 1])
        {
            $item = $arr[$j];
            $arr[$j] = $arr[$j + 1];
            $arr[$j+1] = $item;
            $flag = false;
        }
    }

    // 优化1,无排序即完成,可退出
    if ($flag)
    {
        break;
    }

}

var_dump($arr);
```



#### 优化点2

> 当一个数组接近有序的时候, 只需要在某一个小范围内排序即可, 如  **[1, 7,5,3,9,11,12,13,14]**  ,
>
> 在11后面都已经是有序的情况, 11后面的无需再排序, 可以使用标记来表示这个范围的下限, 只排序到此下标位置即可。

```php
<?php

$arr = [2,-3,-10,4,-5,6,7,8,12,9,1,-11,100,-200,300,400,500];

$len = count($arr);
$index = $len - 1;//排序下限
$maxIndex = 0; //排序上限

for($i = 0; $i < $len - 1; $i++)
{
    //定义标识位标记已经有序或无序
    $flag = true;
    
    for($j = 0; $j < $index; $j++)
    {
        if ($arr[$j] > $arr[$j + 1])
        {
            $item = $arr[$j];
            $arr[$j] = $arr[$j + 1];
            $arr[$j+1] = $item;
            $flag = false;
            $maxIndex = $j;
        }
    }

    // 优化1,无排序即完成,可退出
    if ($flag)
    {
        break;
    }

    /**
     * 优化2
     * 当一个数组接近有序的时候
     * 只需要在某一个小范围内排序即可
     * 使用标记来表示这个范围的下限
     * 只排序到此下标位置即可
     */
    $index = $maxIndex;

}

var_dump($arr);
```



# 斐波那契数列

#### 斐波那契数列递归

```php
<?php

function fibonacci($n)
{
    if($n <= 0) return 0;
    if($n == 1 || $n == 2) return 1;
    return fibonacci($n - 1) + fibonacci($n - 2);
}

// 经过测试, 使用该方法当计算数值达到30以上运算会肉眼可见的明显变慢
for($i = 0; $i < 30; $i++)
{
    var_dump(fibonacci($i));
}
```



#### 递归优化

> 从上面的递归方法可以看到，进行了很多的重复计算，性能极差，N越大，计算的次数越多，既然因为重复计算影响了性能，那么优化就从减少重复计算入手，即把之前计算的存储起来，这样就避免了过多的重复计算，优化了递归算法(但仍然不推荐使用递归)。

```php
<?php

function fibonacci_2($n = 1, $a = 1, $b = 1)
{
    if ($n <= 0) return 0;
    
    if ($n > 2)
    {   // 存储前一位，优化递归计算
        return fibonacci_2($n - 1, $a + $b, $a);
    }

    return $a;
}

// 优化后500内的计算0.2090780735s内可算出来
for($i = 0; $i < 500; $i++)
{
    var_dump(fibonacci_2($i));
}
```



#### 非递归写法(记忆化自底向上)

> 自底向上计算, 把结果存储到数组中, 避免重复计算。

```php
<?php

function fibonacci_3($n)
{
    if ($n <= 0) return 0;
    if ($n <= 2) return 1;

    $list = [0, 1, 1];
    for ($i = 3; $i <= $n; $i++) {
        $list[$i] = $list[$i - 1] + $list[$i - 2];
    }
    
    return $list[$n];// 返回最后一个数，即第N个数
}

for($i = 0; $i < 500; $i++)
{
    var_dump(fibonacci_3($i));
}
```



#### 动态规划

> 进一步优化, 没必要将结果存储到一个数组, 利用动态规划思想, 定义临时变量解决。
>
> 动态规划的思想是，记录中间计算结果，计算后面时，根据前面保存的结果直接计算，避免重复计算且减少存储空间占用。

```php
<?php

function fibonacci_4($n)
{
    if ($n <= 0) return 0;
    if ($n <= 2) return 1;

    $a = 0;
    $b = 1;
    for ($i = 1; $i < $n; $i++) {
        $b = $a + $b;
        $a = $b - $a;
    }
    return $b;
}

for($i = 0; $i < 500; $i++)
{
    var_dump(fibonacci_4($i));
}
```

