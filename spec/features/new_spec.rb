require "spec_helper"

feature "new", js: true do
  context "logged in" do
    scenario "loads" do
      create(:statement)
      visit "/auth/twitter"
      expect(page).to have_content("+")
    end
  end

  context "non logged in" do
    scenario "loads" do
      create(:statement)
      visit "/"
      expect(page).to have_content("+")
    end
  end

  context "filter by type" do
    before do
      s = create(:statement)

      VCR.use_cassette("wikidata/hawking") do
        hawking = create(:individual, name: "Stephen Hawking", wikipedia: "https://whatever")
        create(:agreement, individual: hawking, statement: s, extent: 100)
      end

      not_on_wp = create(:individual, name: "Someone")
      create(:agreement, individual: not_on_wp, statement: s, extent: 100)
      visit "/?min_count=1"
    end

    scenario "should include only influencers (with Wikipedia page) by default" do
      expect(page).to have_content("Stephen Hawking")
      expect(page).not_to have_content("Someone")
    end

    scenario "should include all people regardless of them having Wikipedia page or not" do
      within(:css, "span#type-filter") do
        click_link "influencers"
      end
      click_link "all"

      expect(page).to have_content("Stephen Hawking")
      expect(page).to have_content("Someone")
    end

    scenario "should only include people with no Wikipedia page" do
      within(:css, "span#type-filter") do
        click_link "influencers"
      end
      click_link "people with no Wikipedia page"

      expect(page).not_to have_content("Stephen Hawking")
      expect(page).to have_content("Someone")
    end
  end

  scenario "filter by occupation" do
    s = create(:statement)

    VCR.use_cassette("wikidata/hawking") do
      hawking = create(:individual, name: "Stephen Hawking", wikipedia: "https://whatever")
      hawking.occupation_list.add("writer", "university teacher")
      create(:agreement, individual: hawking, statement: s, extent: 100)
    end

    VCR.use_cassette("wikidata/branson") do
      branson = create(:individual, name: "Richard Branson", wikipedia: "https://whatever")
      branson.occupation_list.add("writer", "entrepreneur")
      create(:agreement, individual: branson, statement: s, extent: 100)
    end

    visit "/?min_count=1"
    expect(page).to have_content("Stephen Hawking")
    expect(page).to have_content("Richard Branson")

    within(:css, "span#occupation-filter") do
      click_link "any"
    end
    click_link "university teacher"

    expect(page).to have_content("Stephen Hawking")
    expect(page).not_to have_content("Richard Branson")
  end

  scenario "filter by school" do
    s = create(:statement)

    VCR.use_cassette("wikidata/hawking") do
      hawking = create(:individual, name: "Stephen Hawking", wikipedia: "https://whatever")
      hawking.school_list.add("Trinity Hall")
      create(:agreement, individual: hawking, statement: s, extent: 100)
    end

    VCR.use_cassette("wikidata/branson") do
      branson = create(:individual, name: "Richard Branson", wikipedia: "https://whatever")
      create(:agreement, individual: branson, statement: s, extent: 100)
    end

    visit "/?min_count=1"
    expect(page).to have_content("Stephen Hawking")
    expect(page).to have_content("Richard Branson")

    within(:css, "span#school-filter") do
      click_link "any"
    end
    click_link "Trinity Hall"

    expect(page).to have_content("Stephen Hawking")
    expect(page).not_to have_content("Richard Branson")
  end
end
