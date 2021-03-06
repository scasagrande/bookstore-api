require 'literate_randomizer'
require 'octokit'
require 'set'

namespace :github do
  desc "Sync database authors with those specificed by the Github issues as per Feature-001"
  task sync: :environment do
    # Get issues from github, which represent individual 
    # authors and their associated biography
    client = Octokit::Client.new
    client.auto_paginate = true
    issues = client.issues 'scasagrande/bookstore-authors'

    # Hash github issue ID and issue data
    authors_gh_h = Hash.new
    issues.each do |issue|
      authors_gh_h[issue[:number]] = issue
    end

    # Retrieve from the DB the list of authors that have matching names
    # to our github list of authors.
    puts "Updating existing authors that have been modified"
    authors_db_to_keep = Author.where(github_issue_id: authors_gh_h.keys)
    authors_db_to_keep_h_set = Set.new  # To be used later when creating authors
    authors_db_to_keep.find_each do |author|
      authors_db_to_keep_h_set.add(author.github_issue_id)
      db_last_update = author.updated_at
      gh_last_update = authors_gh_h[author.github_issue_id][:updated_at]
      if gh_last_update > db_last_update
        puts "Author #{author.name} will be updated"
        author.name = authors_gh_h[author.github_issue_id][:title]
        author.biography = authors_gh_h[author.github_issue_id][:body]
        unless author.save
          fail "Updating author with github issue ID #{author.github_issue_id} failed"
        end
      end
    end

    # Retrieve from the DB the list of authors that no longer have
    # corresponding github issues, and delete them. All books they have 
    # authored are also deleted.
    puts "Deleting authors that have been removed from github"
    Author.where.not(github_issue_id: authors_gh_h.keys).destroy_all

    # Create any new authors with a random new book, priced between $5 and $50
    puts "Creating any new authors, with a random new book"
    authors_gh_h.each do |author_gh_id, author_gh_data|
      next if authors_db_to_keep_h_set.include? author_gh_id

      author_name = author_gh_data[:title]
      author_bio = author_gh_data[:body]

      begin
        Author.transaction do
          puts "Author to be created: #{author_name}"
          author_new = Author.create!(name: author_name, biography: author_bio, github_issue_id: author_gh_id)
          book_title = LiterateRandomizer.sentence :words => 2..4, :punctuation => ""
          book_new = Book.create!(title: book_title, author: author_new, publisher: author_new, price: (rand*45+5).round(2))
        end
      rescue ActiveRecord::RecordInvalid => invalid
        puts "Error creating author #{author_name}, error: #{invalid}"
        raise
      end

    end

    puts "Database has been updated from GitHub"

  end

end
