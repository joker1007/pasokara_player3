require File.join(File.expand_path(File.dirname(__FILE__)), 'spec_helper')

describe 'Jpmobile::Mobile::valid_ip?' do
  [
    [ '210.153.84.1'    , :Docomo    ],
    [ '210.153.84.254'  , :Docomo    ],
    [ '210.230.128.225' , :Au        ],
    [ '210.230.128.238' , :Au        ],
    [ '123.108.237.1'   , :Softbank  ],
    [ '123.108.237.31' , :Softbank  ],
    [ '123.108.237.1'   , :Vodafone  ],
    [ '123.108.237.31' , :Vodafone  ],
    [ '61.198.142.1'    , :Willcom   ],
    [ '61.198.142.254'  , :Willcom   ],
    [ '61.198.142.1'    , :Ddipocket ],
    [ '61.198.142.254'  , :Ddipocket ],
    [ '117.55.1.224'    , :Emobile   ],
    [ '117.55.1.254'    , :Emobile   ],
  ].each do |remote_ip, carrier|
    it "should be return true if #{remote_ip} is in #{:carrier} address" do
      Jpmobile::Mobile.const_get(carrier).valid_ip?(remote_ip).should == true
    end
  end

  [
    [ '127.0.0.1'       , :Docomo    ],
    [ '210.153.83.1'    , :Docomo    ],
    [ '210.153.83.254'  , :Docomo    ],
    [ '127.0.0.1'       , :Au        ],
    [ '210.169.41.1'    , :Au        ],
    [ '210.169.41.254'  , :Au        ],
    [ '127.0.0.1'       , :Softbank  ],
    [ '123.108.238.1'   , :Softbank  ],
    [ '123.108.238.254' , :Softbank  ],
    [ '127.0.0.1'       , :Vodafone  ],
    [ '123.108.238.1'   , :Vodafone  ],
    [ '123.108.238.254' , :Vodafone  ],
    [ '127.0.0.1'       , :Willcom   ],
    [ '61.198.144.1'    , :Willcom   ],
    [ '61.198.144.254'  , :Willcom   ],
    [ '127.0.0.1'       , :Ddipocket ],
    [ '61.198.144.1'    , :Ddipocket ],
    [ '61.198.144.254'  , :Ddipocket ],
    [ '127.0.0.1'       , :Emobile   ],
    [ '117.55.1.223'    , :Emobile   ],
  ].each do |remote_ip, carrier|
    it 'should not be return true if #{:remote_ip} is in #{carrier} address' do
      Jpmobile::Mobile.const_get(carrier).valid_ip?(remote_ip).should_not == true
    end
  end
end
