#ifndef __DERIVATION_TREE_H__
#define __DERIVATION_TREE_H__
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
typedef struct TreeNode{
		char* content;
		struct TreeNode* left;
		struct TreeNode* right;
		struct TreeNode* next;
} TreeNode;
int max(int i , int j);
int tree_length(TreeNode* tn);

void set_tree_node_content(char* content, TreeNode* tn);
TreeNode* create_tree_node(char* content);
void set_left(TreeNode* tn, TreeNode* tleft);
void set_right(TreeNode* tn, TreeNode* tright);
TreeNode* get_right(const TreeNode* tn);
TreeNode* get_left(const TreeNode* tn);
void print_tree_node(const TreeNode* tn, int spaces);
void free_tree_node(TreeNode* tn);
void add_to_left(TreeNode* newNode, TreeNode* tn);
TreeNode* add_end_list_tree_node(TreeNode* start, TreeNode* new);
#endif /* __DERIVATION_TREE_H__ */
