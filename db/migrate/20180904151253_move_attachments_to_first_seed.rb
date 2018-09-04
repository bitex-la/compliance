class MoveAttachmentsToFirstSeed < ActiveRecord::Migration[5.1]
  def up
    with_identifications = Issue.joins(:identification_seeds)
      .select{|i| i.identification_seeds.size > 1 }

    puts "About to fix #{with_identifications.size} IdentificationSeeds"

    with_identifications.each do |i|
      i.identification_seeds[1].attachments
        .update_all(attached_to_seed_id: i.identification_seeds[0].id)
    end

    with_allowance = Issue.joins(:allowance_seeds)
      .select{|i| i.allowance_seeds.size > 1 }

    puts "About to fix #{with_allowance.size} AllowanceSeeds"

    with_allowance.each do |i|
      i.allowance_seeds[1].attachments
        .update_all(attached_to_seed_id: i.allowance_seeds[0].id)
    end

    with_domicile = Issue.joins(:domicile_seeds)
      .select{|i| i.domicile_seeds.size > 1 }

    puts "About to fix #{with_domicile.size} DomicileSeeds"

    with_domicile.each do |i|
      i.domicile_seeds[1].attachments
        .update_all(attached_to_seed_id: i.domicile_seeds[0].id)
    end
  end

  def down
  end
end
