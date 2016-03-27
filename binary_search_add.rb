# THE PROBLEM:
# Given a BST (Binary Search Tree), find 2 values that sum up to a given number.
# Example:
# With the following tree below, find 2 values that add up to 7
#          5
#        /   \
#       3     9
#      / \   / \
#     1   4 7   12
#
# Plausible answer: 4, 3
#
require 'pry-nav'

class BTree
  attr_accessor :value, :left, :right

  def initialize(value)
    @value = value
  end

  def self.init_btree(btree_array)
    btree_length = btree_array.length - 1
    mid_index = btree_length/2

    value = btree_array[mid_index]

    BTree.new(value).tap do |btree|
      btree.left = init_btree(btree_array[0..mid_index-1]) unless btree_length.zero?
      btree.right = init_btree(btree_array[mid_index+1..btree_length]) unless btree_length.zero?
    end
  end
end

class AddSearcher
  attr_reader :btree, :search_value, :result

  class NoSolutionError < StandardError
    def initialize(search_value)
      @search_value = search_value
    end

    def message
      "No Solution for the given value: #{@search_value}"
    end
  end

  def initialize(btree, search_value)
    @btree = btree
    @left_stack = Array.new.push(btree)
    @right_stack = Array.new.push(btree)
    @search_value = search_value
  end

  def setup_right_stack(btree)
    return if btree.nil?
    @right_stack.push(btree)
    setup_right_stack(btree.right)
  end

  def setup_left_stack(btree)
    return if btree.nil?
    @left_stack.push(btree)
    setup_left_stack(btree.left)
  end


  def stack_recursive_search(node_a, node_b)
    #return if node_a.nil? || node_b.nil?
    @@steps = @@steps + 1

    puts "Comparing Values: value_a -> #{node_a.value}, value_b -> #{node_b.value}"
    number_sum = node_a.value + node_b.value

    return { a: node_a.value, b: node_b.value, steps: @@steps } if number_sum == @search_value

    if number_sum > @search_value
      @right_stack.pop.tap { |node| setup_right_stack(node.left) unless node.nil? }
      return stack_recursive_search(node_a, @right_stack.last) unless @right_stack.last.nil?
    else
      @left_stack.pop.tap { |node| setup_left_stack(node.right) unless node.nil? }
      return stack_recursive_search(@left_stack.last, node_b) unless @left_stack.last.nil?
    end

    raise NoSolutionError.new(@search_value) if @right_stack.empty? || @left_stack.empty?
  end

  def start_search
    @@steps = 0
    setup_right_stack(@btree)
    setup_left_stack(@btree)
    stack_recursive_search(@left_stack.last, @right_stack.last)
    rescue NoSolutionError => e
      puts e.message
  end

  def self.setup(value)
    array_1 = [1,3,4,5,7,9,12]
    array_2 = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
    puts "#{array_1.inspect}"
    AddSearcher.new(BTree.init_btree(array_1), value)
  end
end
