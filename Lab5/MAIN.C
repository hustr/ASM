#define _CRT_SECURE_NO_WARNINGS
#include<stdio.h>
#include<stdlib.h>
#include<string.h>

#define G_CNT 4
#define G_SIZE 20
#define S_CNT 2
#define S_SIZE 90


#ifdef __cplusplus
extern "C" {
#endif
    extern char AUTH, S1;
    extern int SHOW_MENU();
    extern void QUERYP(char *goods);
    extern void MODIFYP(char *shop, char *goods);
    extern void CALCU_ALL();
    extern void SORT_PROP();
#ifdef __cplusplus
}
#endif

void prints(char *s) {
    printf("%s", s);
}

int scans(char *s) {
    scanf("%s", s);
    int num = strlen(s);
    return num;
}

void print_allp() {
    char *shop2 = &S1 + S_SIZE;
    char *goods1 = &S1 + 10;
    char *goods2 = shop2 + 10;
    for (int i = 0; i < G_CNT; ++i) {
        printf("%s: \n", goods1);
        short *data1 = (short*)(goods1 + 10);
        short *data2 = (short*)(goods2 + 10);
        printf("In shop1: ");
        printf("sell price: %d, ", data1[1]);
        printf("buy count: %d, ", data1[2]);
        printf("sell count: %d.\n", data1[3]);
        printf("In shop1: ");
        printf("sell price: %d, ", data2[1]);
        printf("buy count: %d, ", data2[2]);
        printf("sell count: %d.\n", data2[3]);
        printf("profile: %d%%, ", data1[4]);
        printf("rank: %d.\n", data2[4]);
        goods1 += G_SIZE;
        goods2 += G_SIZE;
    }
}

void PRINT_NUM(int num) {
    printf("%d", num);
}

int main(void) {
    char name[] = "yaning", passwd[] = "passwd";
    char in_name[100], in_passwd[100];

    while (1) {
        printf("Plase enter user name: ");
        scanf("%s", in_name);
        printf("Please enter passwd: ");
        scanf("%s", in_passwd);
        if (strlen(in_name) == 0) {
            AUTH = 0;
            break;
        }
        if (strcmp(in_name, name) == 0 && strcmp(in_passwd, passwd) == 0) {
            AUTH = 1;
            break;
        }
    }
    char in_shop[20], in_goods[20];
    int choice = 0;
    while (choice != 6) {
        choice = SHOW_MENU();
        switch (choice) {
        case 1:
            printf("Please enter goods name: ");
            scanf("%s", in_goods);
            QUERYP(in_goods);
            break;
        case 2:
            printf("Enter shop name: ");
            scanf("%s", in_shop);
            printf("Enter goods name: ");
            scanf("%s", in_goods);
            MODIFYP(in_shop, in_goods);
            break;
        case 3:
            CALCU_ALL();
            break;
        case 4:
            SORT_PROP();
            break;
        case 5:
            print_allp();
            break;
        case 6:
            break;
        default:
            break;
        }
    }

    return 0;
}
