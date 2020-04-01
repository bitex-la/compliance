module AffinityFinder
    class SamePerson
      def self.call(person)
        # should we check also identification_kind_id and issuer
        Identification.where(
            "number LIKE any :lnumber OR
            :number LIKE CONCAT('%', number, '%')",
            lnumber: "%#{person.identifications.last.number}%",
            number: person.identifications.last.number
        )
        # Creates an issue with AffinitySeed affinity_kind_code: :same_person
        # expiration??
      end
    end
end