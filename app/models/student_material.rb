class StudentMaterial < ActiveRecord::Base
  validates_presence_of :user_id, :lesson_material_id

  belongs_to :user
  belongs_to :lesson_material

  rails_admin do
    list do
      field :id
      field :user
      field :lesson_material
      field :notes
    end

    show do
      field :id
      field :user
      field :lesson_material
      field :notes
    end

    create do
      field :user do
        inline_add false
        inline_edit false
      end
      field :lesson_material do
        inline_add false
        inline_edit false
      end
      field :notes
    end

    edit do
      field :user do
        read_only do
          !(bindings[:view].current_user.admin?)
        end
        inline_add false
        inline_edit false
      end
      field :lesson_material do
        read_only do
          !(bindings[:view].current_user.admin?)
        end
        inline_add false
        inline_edit false
      end
      field :notes
    end
  end
end