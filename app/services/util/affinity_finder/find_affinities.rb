module AffinityFinder
  class FindAffinities
    def self.call(person_id)
      # flowchart
      # start:
      # // person_id
      # /FindAffinities/;
      # branch(a) {
      #   SamePerson;
      #   if (orphan persons_ids?)
      #     loop treatOrphans;

      # }
      # branch(b) {
      #   FinanciallyRelated;
      #   if (orphan persons_ids?)
      #     loop treatOrphans;
      # }
      # return;
      # treatOrphans:
      # removeDuplicates [each person_id];
      # loop start;
    end
  end
end