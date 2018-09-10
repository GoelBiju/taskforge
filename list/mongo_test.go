// Copyright 2018 Mathew Robinson <chasinglogic@gmail.com>. All rights reserved.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

package list

import (
	"context"
	"crypto/md5"
	"encoding/hex"
	"testing"

	"github.com/mitchellh/mapstructure"
)

func makeMongoValidDBName(testName string) string {
	hasher := md5.New()
	hasher.Write([]byte(testName))
	return hex.EncodeToString(hasher.Sum(nil))
}

func TestMongoList(t *testing.T) {
	for _, test := range ListTests {
		dbName := makeMongoValidDBName(test.Name)
		config := Config{
			"url": "mongodb://localhost:27017",
			"db":  dbName,
		}

		l := &MongoList{}

		err := mapstructure.Decode(config, &l)
		if err != nil {
			t.Error(err)
			return
		}

		if err := l.Init(); err != nil {
			t.Errorf("unable to init list: %s", err)
			return
		}

		l.client.Database(dbName).Drop(context.Background())

		t.Run(test.Name, func(t *testing.T) {
			defer l.Disconnect()

			err := test.Test(l)
			if err != nil {
				t.Logf("Test: %s DB: %s\n", test.Name, dbName)
				t.Error(err)
				return
			}
		})
	}
}