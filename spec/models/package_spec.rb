# == Schema Information
#
# Table name: packages
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  version        :string(255)
#  archive_name   :string(255)
#  depends        :text
#  authors        :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  description    :text
#  suggests       :text
#  imports        :text
#  maintainers    :text
#  info_harvested :boolean          default(FALSE), not null
#

require 'spec_helper'

describe Package do
  pending "add some examples to (or delete) #{__FILE__}"
end
