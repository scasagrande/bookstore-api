require 'test_helper'

class BooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @book = books(:one)
  end

  test "should get index" do
    get books_url, as: :json
    assert_response :success
  end

  test "should create book" do
    assert_difference('Book.count') do
      post books_url, params: { data: { attributes: {title: @book.title, price: @book.price}, relationships: {author: {data: {type: "authors", id: @book.author_id}}, publisher: {data: {type: @book.publisher_type, id: @book.publisher_id}}}, type: "books"}}, as: :json
    end

    assert_response 201
  end

  test "should show book" do
    get book_url(@book), as: :json
    assert_response :success
  end

  test "should update book" do
    patch book_url(@book), params: { data: { attributes: {title: @book.title, price: @book.price}, relationships: {author: {data: {type: "authors", id: @book.author_id}}, publisher: {data: {type: @book.publisher_type, id: @book.publisher_id}}}, type: "books"}}, as: :json
    assert_response 200
  end

  test "should destroy book" do
    assert_difference('Book.count', -1) do
      delete book_url(@book), as: :json
    end

    assert_response 204
  end
end
