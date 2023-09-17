class Post < ApplicationRecord
    validates :status, inclusion: { in: StatusConstants::STATUS }

    belongs_to :user, optional: true
    has_many :audits
    mount_uploader :image, ImageUploader
end
