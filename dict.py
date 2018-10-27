persons_Dictionary = {"Joe" : 18, "Bob" : 28, "Alice" : 29, "Callum" : 20, "Donald" : 21, "Emily" : 22}

age_List = [22, 27, 19, 55]
name_List = ["George", "Hope", "Grace", "Alex"]


def add_People(inName_List, inAge_List):
    for i in range(0, len(inName_List)):
        if inName_List[i] in persons_Dictionary:
            persons_Dictionary[inName_List[i]] += 1

        else:
            persons_Dictionary[inName_List[i]] = inAge_List[i]


def add_Person(inName, *inAge):
    if inName in persons_Dictionary and len(inAge) < 1:
        persons_Dictionary[inName] += 1

    else:
        if(len(inAge) == 1):
            persons_Dictionary[inName] = inAge[0]


def main():
    print(persons_Dictionary)

    add_People(name_List, age_List)
    print(persons_Dictionary)

    add_Person("George", 50)
    add_Person("George")
    add_Person("Franny", 12, 55)

    print(persons_Dictionary)

    add_Person("Franny", 23)
    print(persons_Dictionary)

main()
