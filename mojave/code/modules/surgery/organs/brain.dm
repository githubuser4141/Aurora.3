/obj/item/organ/brain
	organ_flags = ORGAN_VITAL | ORGAN_EDIBLE
	food_reagents = list(
		/singleton/reagent/consumable/nutriment/organ_tissue = 4,
		/singleton/reagent/consumable/nutriment/protein = 1,
		/singleton/reagent/consumable/nutriment/protein/prions = 2,
	)
	grind_results = list(
		/singleton/reagent/consumable/nutriment/organ_tissue = 5,
		/singleton/reagent/consumable/nutriment/protein/prions = 5,
	)
	grilled_type = /obj/item/food/meat/steak/plain/ms13/organ/brain
