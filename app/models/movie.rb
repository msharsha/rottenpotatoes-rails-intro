class Movie < ActiveRecord::Base 
    def self.all_ratings
        # retreive all ratings from the DB
        select(:rating).map(&:rating).uniq
    end
    def self.with_ratings(ratings_list)
        # if ratings_list is a valid array return that else if it is nil return all ratings
        if(ratings_list && ratings_list.length)
            where(rating: ratings_list)
        else 
            all
        end
    end
end