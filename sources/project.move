module ScientificDiscoveryDAO::CollaborativeResearch {
    use std::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing a scientific research project
    struct ResearchProject has store, key {
        total_funding: u64,           // Total funds raised for the project
        funding_goal: u64,            // Funding goal for the research
        research_status: bool,        // Project status (active/completed)
        researcher_1: address,        // First researcher
        researcher_2: address,        // Second researcher
        researcher_3: address         // Third researcher (Fixed slots)
    }

    /// Function to initiate a new scientific research project
    public fun create_research_project(
        project_creator: &signer, 
        funding_goal: u64
    ) {
        let creator_address = signer::address_of(project_creator);

        let project = ResearchProject {
            total_funding: 0,
            funding_goal,
            research_status: true,
            researcher_1: creator_address,
            researcher_2: @0x0, // Empty slot
            researcher_3: @0x0  // Empty slot
        };

        // Move the project resource to the creator
        move_to(project_creator, project);
    }

    /// Function for researchers to fund and join a collaborative research project
    public fun contribute_to_research(
        contributor: &signer, 
        project_owner: address, 
        contribution_amount: u64
    ) acquires ResearchProject {
        // Borrow the mutable reference to the research project
        let project = borrow_global_mut<ResearchProject>(project_owner);
        
        // Ensure the project is still active
        assert!(project.research_status, 0);
        
        // Transfer contribution from contributor to project owner
        let contribution = coin::withdraw<AptosCoin>(contributor, contribution_amount);
        coin::deposit<AptosCoin>(project_owner, contribution);
        
        // Update total funding
        project.total_funding = project.total_funding + contribution_amount;
        
        // Add contributor to researchers list if there is an empty slot
        let contributor_addr = signer::address_of(contributor);
        
        if (project.researcher_2 == @0x0) {
            project.researcher_2 = contributor_addr;
        } else if (project.researcher_3 == @0x0) {
            project.researcher_3 = contributor_addr;
        }
    }
}
