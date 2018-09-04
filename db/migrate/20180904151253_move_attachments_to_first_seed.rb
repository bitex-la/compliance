class MoveAttachmentsToFirstSeed < ActiveRecord::Migration[5.1]
  def up
    with_identifications = Issue.joins(:identification_seeds)
      .select{|i| i.identification_seeds.size > 1 }

    all = with_identifications.size
    i = 0
    with_identifications.find_each do |i|
      i += 1
      puts "Fixing IdentificationSeed #{i}/#{all}"
      i.identification_seeds[1].attachments
        .update_all(attached_to_seed_id: i.identification_seeds[0].id)
    end

    with_allowance = Issue.joins(:allowance_seeds)
      .select{|i| i.allowance_seeds.size > 1 }

    all = with_allowance.size
    i = 0
    with_allowance.find_each do |i|
      i += 1
      puts "Fixing Allowance #{i}/#{all}"
      i.allowance_seeds[1].attachments
        .update_all(attached_to_seed_id: i.allowance_seeds[0].id)
    end

    with_domicile = Issue.joins(:domicile_seeds)
      .select{|i| i.domicile_seeds.size > 1 }

    all = with_domicile.size
    i = 0
    with_domicile.find_each do |i|
      i += 1
      puts "Fixing Domicile #{i}/#{all}"
      i.domicile_seeds[1].attachments
        .update_all(attached_to_seed_id: i.domicile_seeds[0].id)
    end
  end

  def down
  end
end
