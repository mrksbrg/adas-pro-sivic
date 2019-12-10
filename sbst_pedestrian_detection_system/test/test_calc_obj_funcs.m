%  Copyright (c) 2019, Markus Borg
%  Copyright (c) 2019, Raja Ben Abdessalem
%  All rights reserved.
%
%  Redistribution and use in source and binary forms, with or without
%  modification, are permitted provided that the following conditions are
%  met:
%
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
%
%  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
%  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
%  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
%  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
%  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
%  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
%  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
%  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
%  POSSIBILITY OF SUCH DAMAGE.
classdef test_calc_obj_funcs < matlab.unittest.TestCase
    
    methods (Test)
        
        function test_pedestrian_awa(testCase)
            actual_min_dist = 0;
            expected_min_dist = 0;
            testCase.verifyEqual(actual_min_dist, expected_min_dist)
            
            actual_min_ttc = 0;
            expected_min_ttc = 0;
            testCase.verifyEqual(actual_min_ttc, expected_min_ttc)
            
            actual_min_dist_awa = 0;
            expected_min_dist_awa = 0;
            testCase.verifyEqual(actual_min_dist_awa, expected_min_dist_awa)
        end
        
        function test_pedestrian_faster(testCase)
            actual_min_dist = 0;
            expected_min_dist = 0;
            testCase.verifyEqual(actual_min_dist, expected_min_dist)
            
            actual_min_ttc = 0;
            expected_min_ttc = 0;
            testCase.verifyEqual(actual_min_ttc, expected_min_ttc)
            
            actual_min_dist_awa = 0;
            expected_min_dist_awa = 0;
            testCase.verifyEqual(actual_min_dist_awa, expected_min_dist_awa)
        end
        
        function test_pedestrian_slower(testCase)
            actual_min_dist = 0;
            expected_min_dist = 0;
            testCase.verifyEqual(actual_min_dist, expected_min_dist)
            
            actual_min_ttc = 0;
            expected_min_ttc = 0;
            testCase.verifyEqual(actual_min_ttc, expected_min_ttc)
            
            actual_min_dist_awa = 0;
            expected_min_dist_awa = 0;
            testCase.verifyEqual(actual_min_dist_awa, expected_min_dist_awa)
        end
        
    end   
end