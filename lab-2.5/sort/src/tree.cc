#include "tree.hh"
#include <sstream>

void Tree::insert(int new_element) {
  // TODO
  if (this->root == nullptr) {
    root = new TreeNode{nullptr, nullptr, new_element};
    return;
  }

  TreeNode* current = this->root;
  while (true) {
    if (new_element < current->value) {
      if (current->lhs == nullptr) {
        current->lhs = new TreeNode{nullptr, nullptr, new_element};
        return;
      } else {
        current = current->lhs;
      }
    } else if (new_element > current->value) {
      if (current->rhs == nullptr) {
        current->rhs = new TreeNode{nullptr, nullptr, new_element};
        return;
      } else {
        current = current->rhs;
      }
    } else {
      return;
    }
  }
}

std::string Tree::description() const {
  std::ostringstream result;
  result << "[";
  auto first = true;

  this->visit([&](auto i) {
    if (first) {
      first = false;
    } else {
      result << ", ";
    }
    result << i;
  });

  result << "]";
  return result.str();
}
