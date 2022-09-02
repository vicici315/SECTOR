def findDuplicate(nums):
    tortoise = nums[0]
    hare = nums[0]
    while True:
        tortoise = nums[tortoise]
        hare = nums[nums[hare]]
        if tortoise == hare:
            break
    
    ptr1 = nums[0]
    ptr2 = tortoise
    while ptr1 != ptr2:
        ptr1 = nums[ptr1]
        ptr2 = nums[ptr2]

    return ptr1

while True:
    num = []
    n = input('Input Numbers(1,2,3):')
    a = n.split(",")
    for i in a:
        num.append(int(i))
    print(findDuplicate(num))

