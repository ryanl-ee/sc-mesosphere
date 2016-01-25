zookeeper '3.4.6' do
  user     'zookeeper'
  mirror   'http://www.poolsaboveground.com/apache/zookeeper'
  checksum '01b3938547cd620dc4c93efe07c0360411f4a66962a70500b163b59014046994'
  action   :install
end

include_recipe "zookeeper::service"

include_recipe "exhibitor::default"
include_recipe "exhibitor::service"
