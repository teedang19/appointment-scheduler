class Instructor < User
  default_scope { where(instructor: true) }

  rails_admin do
    object_label_method do
      :full_name
    end

    list do
      field :id
      field :email
      field :first_name
      field :last_sign_in_at
      field :admin do
        label do
          "Admin?"
        end
      end
    end

    show do
      field :id
      field :instructor
      field :admin
      field :email
      field :full_name
      field :gender
      field :age
      field :skill_level
      field :musical_genre
      field :years_playing
      field :city
      field :state
      field :zip
      field :country
      field :sign_in_count
      field :last_sign_in_at
      field :created_at do
        visible do
          bindings[:view].current_user.admin?
        end
      end
      field :updated_at do
        visible do
          bindings[:view].current_user.admin?
        end
      end
    end

    create do
      field :instructor
      field :admin
      field :email
      field :password
      field :password_confirmation do
        help do
          "Retype password."
        end
      end
      field :first_name
      field :last_name

      field :gender, :enum do
        enum do
          ["male", "female"]
        end
      end

      field :age, :enum do
        enum do
          (18...85).to_a
        end
        help do
          "Optional."
        end
      end

      field :skill_level, :enum do
        enum do
          ["Beginner", "Intermediate", "Advanced", "Master"] 
        end
      end

      field :musical_genre, :enum do
        enum do
          ["Pop", "Jazz", "Classical", "Progressive", "Metal", "Rock", "Country", "Fusion", "Funk", "Other"]
        end
      end

      field :years_playing, :enum do
        enum do
          ["1 - 2", "3 - 5", "5 - 10", "10 +"]
        end
      end
      
      field :city do
        help do
          "Optional. Length up to 255."
        end
      end

      field :state
      field :zip
      field :country do
        help do
          "Optional. Length up to 255."
        end
      end
    end

    edit do
      field :instructor
      field :admin
      field :email

      field :password do
        visible do
          bindings[:object].id == bindings[:controller].current_user.id
        end
        help do
          "Leave blank if you don't want to change."
        end
      end

      field :password_confirmation do
        visible do
          bindings[:object].id == bindings[:controller].current_user.id
        end
        help do
          "Retype new password."
        end
      end

      field :first_name
      field :last_name

      field :gender, :enum do
        enum do
          ["male", "female"]
        end
      end

      field :age, :enum do
        enum do
          (18...85).to_a
        end
        help do
          "Optional."
        end
      end

      field :skill_level, :enum do
        enum do
          ["Beginner", "Intermediate", "Advanced", "Master"] 
        end
      end

      field :musical_genre, :enum do
        enum do
          ["Pop", "Jazz", "Classical", "Progressive", "Metal", "Rock", "Country", "Fusion", "Funk", "Other"]
        end
      end

      field :years_playing, :enum do
        enum do
          ["1 - 2", "3 - 5", "5 - 10", "10 +"]
        end
      end
      
      field :city do
        help do
          "Optional. Length up to 255."
        end
      end
      field :state
      field :zip
      field :country do
        help do
          "Optional. Length up to 255."
        end
      end
    end
  end
end