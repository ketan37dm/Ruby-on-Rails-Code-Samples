module ContactsHelper

  def follow_unfollow_contacts(user)
    if current_user.follows.where(following_id: user.id).count > 0
      link_to("Unfollow", follows_path(user_id: user.id, type: "contacts"), method: :delete, remote: true, class: "btn pull-right unfollow")
    else
      link_to("Follow", follows_path(user_id: user.id, type: "contacts"), remote: true, class: "btn pull-right follow")
    end
  end

  def personal_contact_relationship
    [
      ["Relationship", ""],
      ["Parent", "Parent"],
      ["Guardian", "Guardian"],
      ["GrandParent", "GrandParent"],
      ["Mentor", "Mentor"]
    ]
  end  

  def address_url(address, user)
    address.id.present? ? "#{address_path(:id => user.id)}" : "#{addresses_path(:id => user.id)}"
  end

  def address_method(address)
    address.id.present? ? "put" : "post"
  end

end
