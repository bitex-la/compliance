class MoveAttachmentsToFirstSeed < ActiveRecord::Migration[5.1]
  def up
    with_identifications = Issue.joins(:identification_seeds)

    all = with_identifications.size
    i = 0
    with_identifications.find_each do |issue|
      next unless issue.identification_seeds.size > 1
      i += 1
      puts "Fixing IdentificationSeed #{i}/#{all}"
      issue.identification_seeds[1].attachments
        .update_all(attached_to_seed_id: issue.identification_seeds[0].id)
    end

    with_allowance = Issue.joins(:allowance_seeds)

    all = with_allowance.size
    i = 0
    with_allowance.find_each do |issue|
      next unless issue.allowance_seeds.size > 1
      i += 1
      puts "Fixing Allowance #{i}/#{all}"
      issue.allowance_seeds[1].attachments
        .update_all(attached_to_seed_id: issue.allowance_seeds[0].id)
    end

    with_domicile = Issue.joins(:domicile_seeds)

    all = with_domicile.size
    i = 0
    with_domicile.find_each do |issue|
      next unless issue.domicile_seeds.size > 1
      i += 1
      puts "Fixing Domicile #{i}/#{all}"
      issue.domicile_seeds[1].attachments
        .update_all(attached_to_seed_id: issue.domicile_seeds[0].id)
    end
  end

  def down
  end
end
