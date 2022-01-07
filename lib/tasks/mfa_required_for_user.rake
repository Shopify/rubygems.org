namespace :mfa_required_for_user do
  desc "Set mfa required for owners of top 100 downloaded gems"
  task top_gem_owners: :environment do
    owners = User.joins(rubygems: :gem_download).order("gem_downloads.count DESC").limit(100).uniq

    owners.each do |owner|
      # if owner.mfa_required
      #   puts "👌 #{owner.email} is already required"
      #   next
      # end

      next if owner.mfa_required

      owner.update(mfa_required: true) 
      puts "✅ update #{owner.email} to require mfa"
    end
  end
end

